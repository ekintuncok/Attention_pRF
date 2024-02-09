%%%% ATTENTION PRF  %%%%
%%%%%% Written by Ekin Tuncok
%%% Main script for running different stages of analysis for attention pRF project.

%tbUse spm12
setenv('SUBJECTS_DIR','/Volumes/server/Projects/attentionpRF/derivatives/freesurfer/')
addpath(genpath('~/Documents/MATLAB/toolboxes/GLMDenoise'));
addpath(genpath('~/Documents/MATLAB/toolboxes/GLMsingle'));
addpath(genpath('~/Documents/MATLAB/toolboxes/vistasoft'));
addpath(genpath('~/Documents/MATLAB/toolboxes/mri_tools'));
addpath(genpath('~/Documents/MATLAB/toolboxes/prfVista'));
addpath(genpath('~/Documents/MATLAB/toolboxes/cvncode'));
addpath(genpath('~/Documents/MATLAB/toolboxes/knkUtils'));
addpath(genpath(cd));

path2project      = '/Volumes/server/Projects/attentionpRF/';
addpath(genpath(fullfile(path2project, 'Code')));
figfolder         = fullfile(path2project, 'figfiles');
subject_list      = dir(fullfile(path2project, 'derivatives', 'freesurfer', 'sub-*'));
subject_list(9) = []; % excluded subject

subject_titles = cell(1,length(subject_list));
for sbj_idx = 1:length(subject_list)
    curr_tag = subject_list(sbj_idx).name;
    subject_titles{sbj_idx} = sprintf('sub-%s', curr_tag(11:13));
end

session           = 'nyu3t99';
sessionList       = {'nyu3t01','nyu3t02','nyu3t03','nyu3t04'};
dataFolder        = 'fmriprep';
task              = 'attprf';

designFolder      = 'main';
ROIs = {'V1','V2','V3', 'hV4','V3AB', 'LO1'};

num_iterations = 1000;
bar_loc = 1:48;
attend_up    = 1;
attend_down  = 2;
attend_left  = 3;
attend_right = 4;
attend_neutral = 5;
num_targets  = 4;
mappingStimLeft = [5:9, 35:38];
mappingStimRight = [17:21, 35:38];
mappingStimUpper = [11:14, 29:33];
mappingStimLower = [11:14, 41:45];
MS_overlappng_locs = cat(1, mappingStimUpper, mappingStimLower, mappingStimLeft, mappingStimRight);

%s1_attprf_prepareforGLM(path2project, subject, task, sessionList)
%s2_attprf_prepareforpRFfitting(path2project, subject, session, designFolder)
%s3_attprf_visualizeprfsolutions(path2project, subject, session)
