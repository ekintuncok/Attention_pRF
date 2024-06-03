function [output] = analyze_subject(sessionList, dataConcatenated, resultsDir)
% Set and make the folders for the subject:

figurefold = [resultsDir 'figures'];
if ~exist(figurefold, 'dir')
    mkdir(figurefold);
end
close all
%% ANALYZE MAIN
% main analysis
data = dataConcatenated;
numLocations = 4;
numCueType   = 3;

preCue       = 5;
postCue      = 6;
gaborTilt    = 7;
response     = 8;
reactionTime = 9;
answer       = 10;
for t = 1:length(data)
    if data(t, gaborTilt) == data(t,response)
        data(t,answer) = 1;
    else
        data(t,answer) = 0;
    end
end
%%%%%%%%%%%%%%%%%%
for sesInd = 1:length(sessionList)+1
    % get the responses separately and altogether here:
    if sesInd ~= length(sessionList)+1
        currData = data(data(:,1) == sesInd,:);
        nametag = sessionList{sesInd};
    else
        currData = data;
        nametag = 'average';
    end
    analyzedPrime = zeros(size(currData));
    analyzedPrime(:,1) = currData(:,preCue);
    analyzedPrime(:,2) = currData(:,postCue);
    analyzedPrime(:,3) = currData(:,gaborTilt)  ==  1; % CCW = target absent, CW = target present
    analyzedPrime(:,4) = currData(:,response) ==  1; % CW = "yes",  CCW = "no"
    analyzedPrime(:,7) = currData(:,reactionTime);
    analyzedPrime(:,8) = currData(:,answer);
    
    % Create a new column for the cue type
    % Cue validity (1: valid cue, 2: neutral cue, 3: invalid cue)
    for ind = 1:length(currData)
        if currData(ind, preCue) == 5
            analyzedPrime(ind, 5) = 2;
        elseif currData(ind, preCue) == currData(ind,postCue)
            analyzedPrime(ind, 5) = 1;
        elseif currData(ind, preCue) ~= 5 && currData(ind, preCue) ~= currData(ind,postCue)
            analyzedPrime(ind, 5) = 3;
        end
    end
    
    % Hit             = CW response to CW target
    % False alarm     = CW response to CCW target
    % Miss            = CCW response to CW target
    % Correct reject  = CCW response to CCW target
    
    for ind = 1:length(currData)
        if analyzedPrime(ind, 3) == 1 && analyzedPrime(ind, 4) == 1
            analyzedPrime(ind, 6) = 1; % hits
        elseif analyzedPrime(ind, 3) == 0 && analyzedPrime(ind, 4) == 1
            analyzedPrime(ind, 6) = 2; % false alarms
        end
    end
    
    %% Location specific analysis of d prime
    % parse the data
    conditions = cell(4,1);
    for cueIndex = 1:numLocations
        conditions{cueIndex,1} = analyzedPrime(analyzedPrime(:,2) == cueIndex,:);
    end
    
    % preallocate:
    dprime = zeros(numLocations, numCueType);
    reactionTimeRes = zeros(numLocations, numCueType);
    percentCorrect = zeros(numLocations, numCueType);percentCorrectTags = struct('cueType', []);
    performance = struct('hitRate', [], 'falseAlarmRate', []);
    
    % Run calculations per location:
    for cueIndex = 1:numLocations
        for cueType = 1:numCueType
            currentCond                           = conditions{cueIndex,1}(conditions{cueIndex,1}(:,5) == cueType,:);
            performance(cueIndex).hitRate(cueType)= (sum(currentCond(:,6) == 1)+0.5)/(sum(currentCond(:,3))+1);
            performance(cueIndex).falseAlarmRate(cueType) = (sum(currentCond(:,6) == 2)+0.5)/((length(currentCond)-sum(currentCond(:,3)))+1);
            dprime(cueIndex, cueType)             = norminv(performance(cueIndex).hitRate(cueType))-norminv(performance(cueIndex).falseAlarmRate(cueType));
            reactionTimeRes(cueIndex, cueType)    = mean(currentCond(:,7));
            percentCorrect(cueIndex, cueType)     = sum(currentCond(:,8))/length(currentCond);
            percentCorrectTags(cueIndex).cueType{cueType} = sprintf('%0.2g%%',percentCorrect(cueIndex, cueType));
            if percentCorrect(cueIndex, cueType)  == 1
                percentCorrectTags(cueIndex).cueType{cueType} = sprintf('%0.2g%%', 100);
            end
        end
    end
    %% Run calculations averaged across locations
    % preallocate:
    avgdprime = zeros(1, numCueType);
    avgreactionTimeRes = zeros(1, numCueType);
    avgpercentCorrect = zeros(1, numCueType);avgpercentCorrectTags = struct('cueType', []);
    avgPerformance = struct('hitRate', [], 'falseAlarmRate', []);
    
    for cueType = 1:numCueType
        currentCond = analyzedPrime(find(analyzedPrime(:,5) == cueType),:);
        avgPerformance.hitRate(cueType) = (sum(currentCond(:,6) == 1)+0.5)/(sum(currentCond(:,3))+1);
        avgPerformance.falseAlarmRate(cueType) = (sum(currentCond(:,6) == 2)+0.5)/((length(currentCond)-sum(currentCond(:,3)))+1);
        avgdprime(cueType)              = norminv(avgPerformance.hitRate(cueType))-norminv(avgPerformance.falseAlarmRate(cueType));
        avgreactionTimeRes(cueType)     = mean(currentCond(:,7));
        avgpercentCorrect(cueType)      = sum(currentCond(:,8))/length(currentCond);
        avgpercentCorrectTags.cueType{cueType} = sprintf('%0.2g%%',avgpercentCorrect(cueType));
    end
    
    %% Bootstrapping d prime per location
    avgData{1} = analyzedPrime; %turn it into cell from matrix for statistical simplic
    
    [bootstrappedOutput, CIlower, CIupper]          = bootstrap_behavior(conditions,1);
    [bootstrappedAvgOutput, CIlowerAvg, CIupperAvg] = bootstrap_behavior(avgData,1);
    
    [bootstrappedRT, CIlowerRT, CIupperRT]          = bootstrap_behavior(conditions,2);
    [bootstrappedAvgRT, CIlowerAvgRT, CIupperAvgRT] = bootstrap_behavior(avgData,2);
    
    %% PLOT THE RESULTS %%%%
    titlesxAxis = {'Valid', 'Neutral', 'Invalid'};
    titlesBar   = {'UVM', 'LVM', 'LHM', 'RHM', 'Average'};
    CIlower(5,:) = CIlowerAvg;
    CIupper(5,:) = CIupperAvg;
    dprime(5,:)  = avgdprime;
    
    percentCorrect(5,:) = avgpercentCorrect;
    figure;
    for cueIndex = 1:numLocations+1
        CIhigh = CIupper(cueIndex,:)-dprime(cueIndex,:);
        CIlow = CIlower(cueIndex,:)-dprime(cueIndex,:);
        %      dpriFig = figure('visible','off');
        dpriFig = figure(1);
        sgtitle(nametag)
        subplot(1,5,cueIndex)
        thisBar = bar(dprime(cueIndex,:),'FaceColor', 'flat');
        thisBar.CData = [204, 95, 90; 189,189,189; 42, 76, 101]/255;
        ylim([min(dprime(:))-1,max(dprime(:))+1])
        % Find the Left Most Edge of each X Values bars
        if cueIndex == 1
            ylabel('d''sensitivity index', 'FontSize', 15)
        end
        myLabels = {sprintf('%3.2g%%',percentCorrect(cueIndex,1)),...
            sprintf('%3.2g%%',percentCorrect(cueIndex,2)),...
            sprintf('%3.2g%%',percentCorrect(cueIndex,3))};
        for i = 1:length(myLabels)
            text(i, max(dprime(:))+1, sprintf('%s\n%s\n%s', myLabels{:,i}), ...
                'FontWeight', 'bold', 'horizontalalignment', 'center', 'verticalalignment', 'top');
        end
        title(titlesBar{cueIndex})
        set(gca,'xticklabel',titlesxAxis,'FontSize',15);
        set(gca, 'fontname', 'Arial','FontSize', 12);
        set(gca,'xcolor','k')
        box off
        axis square
        hold on
        % Plot the errorbars
        errBar = errorbar(1:3, dprime(cueIndex,:),CIlow,CIhigh,'k','linestyle','none');
        errBar.LineWidth = 1;
    end
    set(gcf, 'Position', [0 0 1500 400]);
    colorRT = [204, 95, 90; 189,189,189; 42, 76, 101]/255;
    % Reaction time:
    CIlowerRT(5,:) = CIlowerAvgRT;
    CIupperRT(5,:) = CIupperAvgRT;
    reactionTimeRes(5,:)  = avgreactionTimeRes;
    titlesxAxis = {'Valid', 'Neutral', 'Invalid'};
    figure;
    for cueIndex = 1:numLocations+1
        CIhigh = CIupperRT(cueIndex,:)-reactionTimeRes(cueIndex,:);
        CIlow = CIlowerRT(cueIndex,:)-reactionTimeRes(cueIndex,:);
        reactTimefig = figure(2);
        sgtitle(nametag)
        subplot(1,5,cueIndex)
        titlesxAxis = categorical(cellstr(titlesxAxis));
        plot(titlesxAxis(1),reactionTimeRes(cueIndex,1),'o', 'MarkerSize', 10, 'MarkerFaceColor', colorRT(1,:), 'MarkerEdgeColor', colorRT(1,:))
        hold on
        plot(titlesxAxis(2),reactionTimeRes(cueIndex,2),'o', 'MarkerSize', 10, 'MarkerFaceColor', colorRT(2,:), 'MarkerEdgeColor', colorRT(2,:))
        hold on
        plot(titlesxAxis(3),reactionTimeRes(cueIndex,3),'o', 'MarkerSize', 10, 'MarkerFaceColor', colorRT(3,:), 'MarkerEdgeColor', colorRT(3,:))
        ylim([0.1,max(reactionTimeRes(:))+0.1])
        if cueIndex == 1
            ylabel('Reaction Time')
        end
        title(titlesBar(cueIndex))
        set(gca, 'XDir','reverse')
        set(gca, 'fontname', 'Arial','FontSize', 12);
        box off
        axis square
        hold on
        errBar = errorbar(1:3, flip(reactionTimeRes(cueIndex,:)),flip(CIlow),flip(CIhigh),'k','linestyle','none');
        errBar.LineWidth = 1;
    end
    set(gcf, 'Position', [0 0 1200 200]);
    
    % Save the output
    output.raw{sesInd}                = currData;
    output.percentCorrect{sesInd}     = percentCorrect;
    output.dPrime{sesInd}             = dprime;
    output.reactionTime{sesInd}       = reactionTimeRes;
    output.bootstrappedOutput{sesInd} = bootstrappedOutput;
    output.bootstrappedAvgOutput{sesInd} = bootstrappedAvgOutput;
    output.bootstrappedRT{sesInd}        = bootstrappedRT;
    output.bootstrappedAvgRT{sesInd}     = bootstrappedAvgRT;
end
end