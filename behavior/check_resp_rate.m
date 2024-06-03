% check missed trial percentages across subjects:
s0_attentionpRF;
path2project      = '/Volumes/server/Projects/attentionpRF/';
analyzed_beh_path = fullfile(path2project, 'BehaviorData', 'BehaviorAnalyzed');
subject_response_rate = zeros(length(subject_list),1);
for subj_idx = 1:length(subject_list)
    output = load(fullfile(analyzed_beh_path, subject_list(subj_idx).name, sprintf('%s_output.mat', subject_list(subj_idx).name)));
    total_number_trials = (size(output.raw, 2)-1) * 520;
    subject_response_rate(subj_idx) = size(output.raw{size(output.raw, 2)},1)/total_number_trials;
end