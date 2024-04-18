function [TR_event_information] = attpRF_extract_TR_event(path2project, subject)

design_dir = fullfile(path2project, 'derivatives','design_matrices', 'main',sprintf('%s',subject), 'ses-nyu3t99/');
behavior_dir = fullfile(path2project, 'BehaviorData','BehavioralRaw', sprintf('%s/', subject));

design_mat_names = dir(fullfile(behavior_dir, '*experimentalDesignMat*'));
stim_information = [];
for session_idx = 1:length(design_mat_names)
    load([behavior_dir,  design_mat_names(session_idx).name])
    total_time_to_gabors =  design.trialMat(:,5) + design.trialMat(:,6);
    stim_information = cat(1, stim_information, cat(2, design.trialMat(:,2:3), total_time_to_gabors));
end

load([design_dir, sprintf('%s_ses-nyu3t99_task-attprf_design.mat', subject)]);

all_trs = [];
for run_idx = 1:length(design)
    curr_run = design{run_idx};
    % correct for the doubled TR, we have this info already in the timing
    % matrix and we'll incorporate that later on:
    for tr_id = 1:size(curr_run,1)
        if ~isempty(find(curr_run(tr_id,:) == 1))
            curr_stim_idx = find(curr_run(tr_id,:) == 1);
            if curr_run(tr_id+1, curr_stim_idx) == 1
                curr_run(tr_id+1, curr_stim_idx) = 0;
            end
        end
    end
    % concatenate!
    all_trs = cat(1, all_trs, curr_run);
end

% get rid of the gabor event markers since it's modeled on every trial
% anyways:
all_trs(:, 246:end) = [];

TR_event_information = zeros(size(all_trs,1),4);
stim_iter = 1;
for tr_idx = 1:size(all_trs, 1)
    if ~isempty(find(all_trs(tr_idx,:) == 1))
        TR_event_information(tr_idx,1) = 1;
        TR_event_information(tr_idx,2:3) = stim_information(stim_iter,1:2);
        if stim_information(stim_iter, 3) < 2
            TR_event_information(tr_idx+1,1) = 2;
            TR_event_information(tr_idx,4) = 1; % bar duration: 1sec
        else
            TR_event_information(tr_idx+2,1) = 2;
            TR_event_information(tr_idx,4) = 2; % bar duration: 2secs
        end
        stim_iter = stim_iter +1;
    end
end


