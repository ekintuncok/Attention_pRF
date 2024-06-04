%%%% ATTENTION PRF  %%%%
%%%%%% Written by Ekin Tuncok
%%% Main script for running different stages of analysis for attention pRF project

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir)
addpath(genpath(fullfile(scriptDir)));

toolboxPath = input('Please enter the path that contains all dependencies, enter 0 if you are only visualizing the processed data: ', 's');

if ~strcmp(toolboxPath, '0')
    if ~exist(toolboxPath, 'dir')
        warning('Inputted directory does not exist, double check if it is accurate.')
    else
        %%% ---------------- DEPENDENCIES ---------------- %%%
        %setenv('SUBJECTS_DIR','/Volumes/server/Projects/attentionpRF/derivatives/freesurfer/')
        addpath(genpath(fullfile(toolboxPath, 'GLMDenoise')));
        addpath(genpath(fullfile(toolboxPath, 'vistasoft')));
        addpath(genpath(fullfile(toolboxPath, 'mri_tools')));
        addpath(genpath(fullfile(toolboxPath, 'prfVista')));
        addpath(genpath(fullfile(toolboxPath, 'cvncode')));
        addpath(genpath(fullfile(toolboxPath, 'knkUtils')));
        %%% ---------------- DEPENDENCIES ---------------- %%%
    end
    if ~exist(fullfile(toolboxPath, 'GLMDenoise'), 'dir') || ...
            ~exist(fullfile(toolboxPath, 'vistasoft'), 'dir') || ...
            ~exist(fullfile(toolboxPath, 'mri_tools'), 'dir') || ...
            ~exist(fullfile(toolboxPath, 'prfVista'), 'dir') || ...
            ~exist(fullfile(toolboxPath, 'cvncode'), 'dir') || ...
            ~exist(fullfile(toolboxPath, 'knkUtils'), 'dir')
        warning('At least one dependency is missing in the path, double check if it resides in the toolboxPath')
    else
        fprintf('All dependencies added successfully.\n');
    end
end

cd .. % go back to the main folder
path2project      = pwd; %  define the main project directory
subject_list      = dir(fullfile(path2project, 'BehaviorData', 'BehaviorAnalyzed', 'sub-*'));
subject_list(9) = []; % excluded subject
cd(scriptDir); % go back to the code directory
subject_titles = cell(1,length(subject_list));
for sbj_idx = 1:length(subject_list)
    curr_tag = subject_list(sbj_idx).name;
    subject_titles{sbj_idx} = sprintf('sub-%s', curr_tag(11:13));
end
session           = 'nyu3t99';
sessionList       = {'nyu3t01','nyu3t02','nyu3t03','nyu3t04'};
dataFolder        = 'fmriprep';
task              = 'attprf';
designFolder      = 'main'; % this could be 'shuffled' for the control analysis of pRF center shifts.
ROIs = {'V1','V2','V3', 'hV4','V3AB', 'LO1'};

% Save the configuration
save('config.mat', 'toolboxPath', 'path2project', 'subject_list','sessionList','ROIs');

%s1_attprf_prepareforGLM(path2project, subject, task, sessionList)
%s2_attprf_prepareforpRFfitting(path2project, subject, session, designFolder)
%s3_attprf_visualizeprfsolutions(path2project, subject, session)
