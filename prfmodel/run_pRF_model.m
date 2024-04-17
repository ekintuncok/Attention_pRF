function results = run_pRF_model(subject_info, glm_folder)

% This function runs pRF model on attention pRF subject data using prfVistasoft
% wrapper, and VistaLab software.
% Example calls:
% results = run_pRF_model('wlsubj123', 'avg_betas')
% results = run_pRF_model('wlsubj123', 'main')
% results = run_pRF_model('wlsubj123', 'shuffled')

addpath(genpath('/scratch/et2160/toolboxes/vistasoft'));
addpath(genpath('/scratch/et2160/toolboxes/prfVista'));

path2project      = '/scratch/et2160/attentionpRF/';
hemispheres = {'lh','rh'};
stim = fullfile(path2project, 'Stim', 'stim.mat');
subject = subject_info;
stimradius = 12;

% force the condition to be equal to one if average betas are inputted to
% the pRF model:
if strcmp(glm_folder, 'avg_betas')
    numCond = 1;
    cond_folder = {'avg'};
    % the condition refers to which attentional cueing produced the
    % corresponding beta coefficients, goes from 1 to 5 for attend up, down,
    % left, right and distributed. All this data reside in the main glmdenoise
    % folder. The avg_betas folder has the averaged beta coefficients across
    % attention conditions. There is only one condition option for this folder
    % (1).
else
    numCond = 1:5;
    cond_folder = {'1','2','3','4','5'};
end

if strcmp(glm_folder, 'main') || strcmp(glm_folder, 'avg_betas')
    prf_folder = 'prfFolder_2';
elseif strcmp(glm_folder, 'shuffled')
    prf_folder = 'shuffled';
end

glm_results_dir = fullfile(path2project, 'derivatives', 'GLMdenoise', glm_folder);
prf_results_dir = fullfile(path2project, 'derivatives', 'prfs');
for c = 1:length(numCond)
    for h = 1:length(hemispheres)
        fprintf('>>>> Currently running the %s model on subject: %s condition: %s hemisphere: %s\n', glm_folder, subject, cond_folder{c}, hemispheres{h}); 

        data = fullfile(glm_results_dir, sprintf('sub-%s/ses-nyu3t99/niftifiles/%s.modelmd.%i.nii.gz', subject, hemispheres{h}, numCond(c)));

        % we will set some default steps to 0 here. This is because instead of
        % fMRI time series, we are using the beta coefficients representing the
        % mapping stimulus location from GLM. We will set detrending,
        % decimating and percent change calculation to 0, we will also change
        % the hrf to none (or impulse function):
        results = prfVistasoft(stim, data, stimradius,...
            'tr', 1, 'detrend', 0, 'hrfparams', 'none', 'decimate',0, 'calcPC', false);

        save_folder = fullfile(prf_results_dir, sprintf('sub-%s/ses-nyu3t99/%s/%s/', subject, prf_folder, cond_folder{c}));
        if ~exist(save_folder, 'dir')
            mkdir(save_folder);
        end
        save(fullfile(save_folder, sprintf('%s.prfFit.wholeBrain.mat', hemispheres{h})), '-v7.3')
    end
end

