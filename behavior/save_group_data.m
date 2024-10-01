function save_group_data(path2project,subjList,by_ms_loc)

analyzed_beh_path = fullfile(path2project, 'BehaviorData', 'BehaviorAnalyzed');

close all;
numconds = 5;
numcuetype = 3;

if by_ms_loc == true
    sb_output_tag = 'output_by_ms_loc';
    gr_sens_output_tag = 'behavioral_sensitivity_by_ms_loc';
    gr_RT_output_tag = 'reaction_time_by_ms_loc';
else
    sb_output_tag = 'output';
    gr_sens_output_tag = 'behavioral_sensitivity';
    gr_RT_output_tag = 'reaction_time';
end


dpri_data = zeros(numconds, numcuetype,length(subjList));
rt_data = zeros(numconds, numcuetype,length(subjList));

for subj_idx = 1:length(subjList)
    output = load(fullfile(analyzed_beh_path, subjList(subj_idx).name, sprintf('%s_%s.mat', subjList(subj_idx).name, sb_output_tag)));
    dpri_avg_idx =  size(output.dPrime,2);
    rt_avg_idx =  size(output.reactionTime,2);
    rt_data(:,:, subj_idx) = output.reactionTime{1,rt_avg_idx};
    dpri_data(:,:, subj_idx) = output.dPrime{1,dpri_avg_idx};
end


save([analyzed_beh_path sprintf('/%s.mat', gr_sens_output_tag)], 'dpri_data');
save([analyzed_beh_path sprintf('/%s.mat', gr_RT_output_tag)], 'rt_data');


