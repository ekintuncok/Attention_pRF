% extract average gaze position for each scan session for separate precue
% conditions:
s0_attentionpRF;
filename2 = '/usr/local/bin/edf2asc';
edf_run_tags = {'01','02','03','04','05','06','07','08','09','10'};
eye_data_dir = '/Volumes/server/Projects/attentionpRF/EDFfiles';
path2designmat = '/Volumes/server/Projects/attentionpRF/BehaviorData/BehavioralRaw';
data = [];
x_pixels = 1920;
y_pixels = 1080;
center_X = x_pixels/2;
center_Y = y_pixels/2;

ScreenHeight     = 36.2;
ViewDistance     = 85;
visual_angle = (2*atand(ScreenHeight/(2*ViewDistance)));
ppd = round(y_pixels/visual_angle);
num_sessions = 4;
num_runs = 10;

proportion_deviated = zeros(length(subject_list), num_sessions, num_runs);
for subj_idx = 1:length(subject_list)
    subject = subject_list(subj_idx).name;
    disp(subject)
    session_list = dir(fullfile(path2designmat, subject, '*experimentalDesignMat*'));
    for session_idx = 1:length(session_list)
        session = sprintf('ses-nyu3t0%i', session_idx);
        session_gaze_data = [];
        session_pupil_data = [];
        gaze_position = zeros(52, 7);
        for run_idx = 1:length(edf_run_tags)
            if exist(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})), 'file')
                load(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})));
                data(:,1) = (data_run(:,7) - center_X)/ppd;
                data(:,2) = (data_run(:,8) - center_Y)/ppd;
                proportion_deviated(subj_idx, session_idx, run_idx) = attpRF_calculate_eye_deviation(data);
            else
                fprintf('Warning: no data for the current run %i\n', run_idx);
                proportion_deviated(subj_idx, session_idx, run_idx) = NaN;
            end
            data = [];
        end
    end
end

proportion_deviated_averaged = mean(mean(proportion_deviated, 3, 'omitnan'), 2, 'omitnan');
[lw_ci, up_ci]=calculate_bootstrapped_confidence_interval(proportion_deviated_averaged, 'mn');


