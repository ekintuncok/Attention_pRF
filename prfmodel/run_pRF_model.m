function results = run_pRF_model(subject_info, condition, glm_folder)

addpath(genpath('/scratch/et2160/toolboxes/vistasoft'));
addpath(genpath('/scratch/et2160/toolboxes/prfVista'));

path2project      = '/scratch/et2160/attentionpRF/';
hemispheres = {'lh','rh'};
stim = fullfile(path2project, 'Stim', 'stim.mat');
subject = subject_info;
stimradius = 12;
glm_results_dir = fullfile(path2project, 'derivatives', 'GLMdenoise', glm_folder);
prf_results_dir = fullfile(path2project, 'derivatives', 'prfs');
for h = 1:length(hemispheres)
    fprintf('Running subject = %s, hemisphere = %s\n',subject_info, hemispheres{h});

    data = fullfile(glm_results_dir, sprintf('sub-%s/ses-nyu3t99/niftifiles/%s.modelmd.%i.nii.gz', subject, hemispheres{h}, condition));

    % we will set some default steps to 0 here. This is because instead of
    % fMRI time series, we are using the beta coefficients representing the
    % mapping stimulus location from GLM. We will set detrending,
    % decimating and percent change calculation to 0, we will also change
    % the hrf to none (or impulse function): 
    results = prfVistasoft(stim, data, stimradius,...
        'tr', 1, 'detrend', 0, 'hrfparams', 'none', 'decimate',0, 'calcPC', false);

    save_folder = fullfile(prf_results_dir, sprintf('sub-%s/ses-nyu3t99/prfFolder_2/avg/', subject));
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    save(fullfile(save_folder, sprintf('%s.prfFit.wholeBrain.mat', hemispheres{h})), '-v7.3')
end

