function [output, CIlower, CIupper] = attpRF_behavior_bootstrapData(data,type)
%%%% ATTENTION PRF %%%%
% type == 1 bootstraps dprime, type == 2 bootstraps reaction time
%% Bootstrap
% Written by Ekin Tuncok
% 10/2021

% Data averaged across conditions will be a cell with one element, so this
% is to index the type of data
if size(data,1) > 1
    numLocs = 4;
else
    numLocs = 1;
end

numCues = 3;

if iscell(data)
    for ii = 1:numLocs
        parsedValid{ii}   =  data{ii}(find(data{ii}(:,5) == 1),:);
        parsedNeutral{ii} =  data{ii}(find(data{ii}(:,5) == 2),:);
        parsedInvalid{ii} =  data{ii}(find(data{ii}(:,5) == 3),:);
    end
end

% Type 1 input calculates the d prime CI
if type == 1
    numIter = 1000;
    for iter = 1:numIter
        for ii = 1:numLocs
            bootValid{iter} = datasample(parsedValid{ii},length(parsedValid{ii}));
            bootNeutral{iter} =  datasample(parsedNeutral{ii},length(parsedNeutral{ii}));
            bootInvalid{iter} =  datasample(parsedInvalid{ii},length(parsedInvalid{ii}));
            performanceValid(iter).hitRate(ii) = (sum(bootValid{iter}(:,6) == 1)+0.5)/(sum(bootValid{iter}(:,3))+1);
            performanceValid(iter).falseAlarmRate(ii) = (sum(bootValid{iter}(:,6) == 2)+0.5)/((length(bootValid{iter})-sum(bootValid{iter}(:,3)))+1);
            performanceNeutral(iter).hitRate(ii) = (sum(bootNeutral{iter}(:,6) == 1)+0.5)/(sum(bootNeutral{iter}(:,3))+1);
            performanceNeutral(iter).falseAlarmRate(ii) = (sum(bootNeutral{iter}(:,6) == 2)+0.5)/((length(bootNeutral{iter})-sum(bootNeutral{iter}(:,3)))+1);
            performanceInvalid(iter).hitRate(ii) = (sum(bootInvalid{iter}(:,6) == 1)+0.5)/(sum(bootInvalid{iter}(:,3))+1);
            performanceInvalid(iter).falseAlarmRate(ii) = (sum(bootInvalid{iter}(:,6) == 2)+0.5)/((length(bootInvalid{iter})-sum(bootInvalid{iter}(:,3)))+1);
            
            % compute d
            dprimeV(iter, ii) = norminv(performanceValid(iter).hitRate(ii))-norminv(performanceValid(iter).falseAlarmRate(ii));
            dprimeN(iter, ii) = norminv(performanceNeutral(iter).hitRate(ii))-norminv(performanceNeutral(iter).falseAlarmRate(ii));
            dprimeI(iter, ii) = norminv(performanceInvalid(iter).hitRate(ii))-norminv(performanceInvalid(iter).falseAlarmRate(ii));
        end
    end
    output = cell(1,numLocs);
    for ii = 1:numLocs
        output{ii} = [dprimeV(:,ii), dprimeN(:,ii), dprimeI(:,ii)];
    end
    
    p = 68;
    calculateCI = @(x,p)prctile(x,abs([0,100]-(100-p)/2));
    
    for ii = 1:numLocs
        for jj = 1:numCues
            results = calculateCI(output{ii}(:,jj), p);
            CIlower(ii,jj) = results(1);
            CIupper(ii,jj) = results(2);
        end
    end
    % Type 2 input calculates the reaction time CI
    
else
    numIter = 1000;
    for iter = 1:numIter
        for ii = 1:numLocs
            bootValid{iter} = datasample(parsedValid{ii},length(parsedValid{ii}));
            bootNeutral{iter} =  datasample(parsedNeutral{ii},length(parsedNeutral{ii}));
            bootInvalid{iter} =  datasample(parsedInvalid{ii},length(parsedInvalid{ii}));
            reactionTimeV(iter,ii)  = mean(bootValid{iter}(:,7));
            reactionTimeN(iter,ii)  = mean(bootNeutral{iter}(:,7));
            reactionTimeI(iter,ii)  = mean(bootInvalid{iter}(:,7));
        end
    end
    
    output = cell(1,numLocs);
    for ii = 1:numLocs
        output{ii} = [reactionTimeV(:,ii), reactionTimeN(:,ii), reactionTimeI(:,ii)];
    end
    
    p = 68;
    calculateCI = @(x,p)prctile(x,abs([0,100]-(100-p)/2));
    
    for ii = 1:numLocs
        for jj = 1:numCues
            results = calculateCI(output{ii}(:,jj), p);
            CIlower(ii,jj) = results(1);
            CIupper(ii,jj) = results(2);
        end
    end
end
end