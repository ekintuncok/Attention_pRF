% eye tracker accuracy:

if ~ exist('config.mat','file')
    s0_attentionpRF;
else
    load('config.mat');
end

for subj_idx = 2:length(subject_list)
    subject = subject_list(subj_idx).name;
    disp(subject)
    for session_idx = 1:length(session_list)
        session = sprintf('ses-nyu3t0%i', session_idx);
        load(fullfile(path2project, 'EDFfiles',sprintf('%s', subject), sprintf('%s',session), ...
            'MATs/calibration_accuracy.mat'))
    end
end
