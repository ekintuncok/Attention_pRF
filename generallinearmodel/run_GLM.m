function run_GLM(subject_info)

addpath(genpath('/scratch/et2160/toolboxes/mri_tools'));
addpath(genpath('/scratch/et2160/toolboxes/GLMDenoise'));
addpath(genpath('/scratch/et2160/toolboxes/knkutils'));
addpath(genpath('/scratch/et2160/toolboxes/vistasoft'));
addpath(genpath('/scratch/et2160/toolboxes/jsonlab_v1.2'));


path2project = '/scratch/et2160/attentionpRF';
subject      = subject_info;
fprintf('%s\n', subject);
session      = 'nyu3t99';
task         = 'attprf';
runnums      = 1:40;
dataFolder   = 'fmriprep';
dataStr      = 'mgz';
designFolder = 'main';
stimdur      = 1;
tr           = 1;

results = bidsGLM(path2project, subject, session, task, runnums, dataFolder, dataStr, designFolder, stimdur, [], [], tr);

end
