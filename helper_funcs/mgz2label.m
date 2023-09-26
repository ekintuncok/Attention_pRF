function mgz2label(path2project, subject, atlas)

labelfolder = fullfile(path2project, 'derivatives','freesurfer', sprintf('sub-%s', subject), 'label');
path2fs           = fullfile(path2project,  'derivatives', 'freesurfer', sprintf('sub-%s', subject));

if strcmp(atlas,'handDrawn')
    tag = 'ROIs_V1-3';
    roiname_array={'V1', 'V2', 'V3'};
elseif strcmp(atlas,'wangAtlas')
    tag = 'wang2015_atlas';
    roiname_array={'V1v', 'V1d', 'V2v', 'V2d', 'V3v' ,'V3d' ,'hV4', 'VO1' ,'VO2' ,'PHC1' ,'PHC2' ,'TO2', ...
    'TO1' ,'LO2', 'LO1', 'V3B' ,'V3A', 'IPS0' ,'IPS1', 'IPS2' ,'IPS3' ,'IPS4', 'IPS5', 'SPL1', 'FEF'};
end

% list of ROI names Wang atlas (2015) is mapping:
freesurfer_init;
for r = 1:length(roiname_array)
    
    system(sprintf('%smri_cor2label --i %s/surf/lh.%s.mgz --id %i --l %s/lh.%s.%s.label --surf %s lh inflated', ...
        freesurfer_string,path2fs,tag, r,labelfolder,tag, roiname_array{r},['sub-' subject]))

    system(sprintf('%smri_cor2label --i %s/surf/rh.%s.mgz --id %i --l %s/rh.%s.%s.label --surf %s rh inflated', ...
        freesurfer_string,path2fs,tag, r,labelfolder,tag, roiname_array{r},['sub-' subject]))
end

% check which ROIs have been labeled:
for r = 1 : length(roiname_array)
    fprintf('%i %s\n',r,roiname_array{r});
end
end

