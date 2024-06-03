% This script analyzes the behavioral data at a group level for both
% behavioral sensitivity and reaction time

path2project      = '/Volumes/server/Projects/attentionpRF/';
analyzed_beh_path = fullfile(path2project, 'BehaviorData', 'BehaviorAnalyzed');
subjList    = dir(fullfile(analyzed_beh_path,'sub*'));
subjList(9) =[];
close all;
numconds = 5;
numcuetype = 3;

dpri_data = zeros(numconds, numcuetype,length(subjList));
for subj_idx = 1:length(subjList)
    output = load(fullfile(analyzed_beh_path, subjList(subj_idx).name, sprintf('%s_output.mat', subjList(subj_idx).name)));
    dpri_avg_idx =  size(output.dPrime,2);
    dpri_data(:,:, subj_idx) = output.dPrime{1,dpri_avg_idx};
end
save([analyzed_beh_path '/behavioral_sensitivity.mat'], 'dpri_data');

% extract group RT
rt_data = zeros(numconds, numcuetype,length(subjList));
for subj_idx = 1:length(subjList)
    output = load(fullfile(analyzed_beh_path, subjList(subj_idx).name, sprintf('%s_output.mat', subjList(subj_idx).name)));
    rt_avg_idx =  size(output.reactionTime,2);
    rt_data(:,:, subj_idx) = output.reactionTime{1,rt_avg_idx};
end
save([analyzed_beh_path '/reaction_time.mat'], 'rt_data');

