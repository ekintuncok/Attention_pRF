function gii2nii(path2project, subject, sessionList)

newsession = 'nyu3t99'; % fake session name and directory for concatenated data 
newSessionDir     = fullfile(path2project, 'derivatives', 'fmriprep',...
    sprintf('sub-%s', subject), sprintf('ses-%s', newsession), 'func/');

if ~exist(newSessionDir,'dir')
    mkdir(newSessionDir)
end

numRunsinSessions = zeros(1,length(sessionList));

for sessionInd = 1:length(sessionList)
    session           = sessionList(sessionInd);
    path2subj = fullfile(path2project, 'derivatives','fmriprep', sprintf('sub-%s', subject), sprintf('ses-%s', session{1}), 'func/');
    runs = dir(sprintf('%s/*fsnative*.gii',path2subj));
    
    % converts from .gii to .nii, and .nii to .mgz
    for f = 1:length(runs)
        [~,mainname,~] = fileparts(runs(f).name);
        [mytmpname] = [runs(f).folder filesep mainname];
        if ~exist(sprintf('%s.nii.gz',mytmpname),'file')
            system(sprintf('mri_convert %s.gii %s.nii.gz',mytmpname,mytmpname));
        end
        if ~exist(sprintf('%s.mgz',mytmpname),'file')
            system(sprintf('mri_convert %s.nii.gz %s.mgz',mytmpname,mytmpname));
        end
    end

    %separates the nifti files based on the hemisphere
    runsLeft  = dir(sprintf('%s*space-fsnative_hemi-L_*.mgz',path2subj));
    runsRight = dir(sprintf('%s*space-fsnative_hemi-R_*.mgz',path2subj));

    numRunsinSessions(sessionInd) = length(runsRight);
   
    % runs through the niftis for the given session, moves them to the new folder
   
    for r = 1:length(runsLeft)
        movefile([path2subj runsLeft(r).name],  [newSessionDir runsLeft(r).name]);
        movefile([path2subj runsRight(r).name], [newSessionDir runsRight(r).name]);
    end

    for r = 1:length(runsLeft)
        % change run numbers from 1 to 30 in the concatenated folder:
        if sessionInd == 1
            renameRun = [10, 1:9]; % 10 is the first one on the name list
        else
            renameRun = [10, 1:9] + sum(numRunsinSessions(1:sessionInd-1));
        end
        movefile([newSessionDir runsLeft(r).name],...
            [newSessionDir sprintf('sub-%s_ses-nyu3t99_task-attprf_acq-PA_run-%i_space-fsnative_hemi-L_bold.func.mgz',subject, renameRun(r))]);
        movefile([newSessionDir runsRight(r).name],...
            [newSessionDir sprintf('sub-%s_ses-nyu3t99_task-attprf_acq-PA_run-%i_space-fsnative_hemi-R_bold.func.mgz',subject, renameRun(r))]);
    end
end