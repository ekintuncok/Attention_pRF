subjectList      = dir(fullfile(path2project, 'derivatives', 'freesurfer', 'sub-*'));
subjectList(9) = [];
statsDir   = sprintf('/Volumes/server/Projects/attentionpRF/BehaviorData/Stats');
type = 'reactionTime';
%%%%% ATTENTION PRF: behavioral analysis with repeated measures ANOVA
results = cell(1,length(subjectList));
for subjInd = 1:length(subjectList)
    subject = subjectList(subjInd).name;
    resultsDir = sprintf('/Volumes/server/Projects/attentionpRF/BehaviorData/BehaviorAnalyzed/%s/',subject);
    load([resultsDir sprintf('/%s_output.mat',subject)], type);
    if strcmp(type, 'dPrime')
        results{subjInd} = dPrime;
    elseif strcmp(type, 'reactionTime')
        results{subjInd} = reactionTime;
    end
end

varCode = {'Y1','Y2','Y3','Y4','Y5','Y6','Y7','Y8','Y9','Y10','Y11','Y12'};
dataFormatted = [];
for ind = 1:length(subjectList)
    subj_data_avg = cell2mat(results{ind}(1,end)');
    subj_data_avg = subj_data_avg(1:4,:);
    dataFormatted = [dataFormatted reshape(subj_data_avg',[],1)];
end

dataFormatted = dataFormatted';
t = array2table(dataFormatted,'VariableNames',varCode);
factorNames = {'Location','CueType'};
within = table({'L1';'L1';'L1';'L2';'L2';'L2';'L3';'L3';'L3';'L4';'L4';'L4'}...
    ,{'C1';'C2';'C3';'C1';'C2';'C3';'C1';'C2';'C3';'C1';'C2';'C3'},'VariableNames',factorNames);
rm = fitrm(t,'Y1-Y12~1','WithinDesign',within);
[ranovatbl] = ranova(rm, 'WithinModel','Location*CueType');
[multComp]  = multcompare(rm,'CueType','By','Location', 'ComparisonType','bonferroni');

mauchly(rm)

alphal =0.05;
[p_variance_test,stats] = vartestn(dataFormatted);
chisq = stats.chisqstat;
for ii = 1:size(dataFormatted,2)
    [H_normality(ii), p_normality(ii), ~] = swtest(dataFormatted(:,ii), alphal);
end

save([statsDir sprintf('/%s.ANOVAtable.mat',type)], 'ranovatbl');
save([statsDir sprintf('/%s.multipleComparisons.mat',type)], 'multComp');


