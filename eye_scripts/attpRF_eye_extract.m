s0_attentionpRF;
filename2 = '/usr/local/bin/edf2asc';

% set the directories and run labels:
edf_run_tags = {'01','02','03','04','05','06','07','08','09','10'};
eye_data_dir = '/Volumes/server/Projects/attentionpRF/EDFfiles';
path2designmat = '/Volumes/server/Projects/attentionpRF/BehaviorData/BehavioralRaw';
data = [];
num_trials_per_run = 52;

for subj_idx = 2:length(subject_list)
    subject = subject_list(subj_idx).name;
    disp(subject)
    session_list = dir(fullfile(path2designmat, subject, '*experimentalDesignMat*'));
    subject_gaze_data = [];
    for session_idx = 1:length(session_list)
        session = sprintf('ses-nyu3t0%i', session_idx);
        session_gaze_data = [];
        gaze_position = zeros(num_trials_per_run, 7);
        for run_idx = 1:length(edf_run_tags)
            if exist(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})), 'file')
                load(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})));
                load(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_blink.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})));
                for trial_number = 1:num_trials_per_run
                    % extract the gaze data:
                    curr_timepoints = data_run(:,4) == trial_number;
                    trial_eye_pos = data_run(curr_timepoints, :);
                    fixation_post = data_run(find(trial_eye_pos(:,10)==1), 7:8);
                    gaze_during_fx = median(fixation_post);
                    ms_id = find(trial_eye_pos(:,10)==2);
                    gb_id = find(trial_eye_pos(:,10)==3);
                    if isempty(ms_id) && ~isempty(gb_id)
                        average_gaze_post = mean(trial_eye_pos(gb_id(1):gb_id(end), 7:8));
                    elseif isempty(gb_id) && ~isempty(ms_id)
                        average_gaze_post = mean(trial_eye_pos(ms_id(1):ms_id(end), 7:8));
                    elseif isempty(ms_id) && isempty(gb_id)
                        average_gaze_post = [NaN, NaN];
                    else
                        average_gaze_post = mean(trial_eye_pos(ms_id(1):gb_id(end), 7:8));
                    end
                    gaze_position(trial_number, 1) = subj_idx;
                    gaze_position(trial_number, 2) = session_idx;
                    gaze_position(trial_number, 3) = run_idx;
                    gaze_position(trial_number, 4) = trial_number;
                    time_stamp = data_run(curr_timepoints, 6);
                    stamp_for_trial_cond = find(data_run(:,6) == time_stamp(1));
                    gaze_position(trial_number, 5) = data_run(stamp_for_trial_cond, 5);
                    gaze_position(trial_number, 6:7) = average_gaze_post;
                    gaze_position(trial_number, 8:9) = gaze_during_fx;
                end
            else
                fprintf('Warning: no data for the current run %i\n', run_idx)
                gaze_position = NaN(num_trials_per_run, 9);
            end
            session_gaze_data = cat(1, session_gaze_data, gaze_position);
        end
        subject_gaze_data = cat(1, subject_gaze_data, session_gaze_data);
    end
    data = cat(1, data, subject_gaze_data);
end

save(fullfile(path2project, 'EDFfiles/EyeAnalyzed/EyeData2.mat'), 'data')

