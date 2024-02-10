function results = run_pRF_model_local(subject_info, condition)


addpath(genpath('/Documents/MATLAB/toolboxes/vistasoft'));
addpath(genpath('/Documents/MATLAB/toolboxes/prfVista'));

path2project      = '/Volumes/server/Projects/attentionpRF/';
hemispheres = {'lh','rh'};
stim = fullfile(path2project, 'Stim', 'stim.mat');
subject = subject_info;
stimradius = 12;

for h = 1:length(hemispheres)
    fprintf('Running subject = %s, hemisphere = %s\n',subject_info, hemispheres{h});

    data = fullfile(path2project, 'derivatives', 'GLMdenoise/main/',...
        sprintf('sub-%s/ses-nyu3t99/niftifiles/%s.modelmd.%i.nii.gz', subject, hemispheres{h}, condition));

    % we will set some default steps to 0 here. This is because instead of
    % fMRI time series, we are using the beta coefficients representing the
    % mapping stimulus location from GLM. We will set detrending,
    % decimating and percent change calculation to 0, we will also change
    % the hrf to none (or impulse function): 
    results = prfVistasoft(stim, data, stimradius,...
        'tr', 1, 'detrend', 0, 'hrfparams', 'none', 'decimate',0, 'calcPC', false);

    save_folder = fullfile(path2project, 'derivatives/prfs',sprintf('sub-%s/ses-nyu3t99/prfFolder_2/try_remodel/%i', subject, condition));
    if ~exist(save_folder, 'dir')
        mkdir(fullfile(path2project, 'derivatives/prfs',sprintf('sub-%s/ses-nyu3t99/prfFolder_2/try_remodel/%i', subject, condition)));
    end
    save(fullfile(path2project, 'derivatives/prfs', ...
        sprintf('sub-%s/ses-nyu3t99/prfFolder_2/try_remodel/%i/%s.prfFit.wholeBrain.mat', subject, condition, hemispheres{h})), '-v7.3')
end

