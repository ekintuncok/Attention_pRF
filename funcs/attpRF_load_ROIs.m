function labels = attpRF_load_ROIs(path2project, subject)

path2fs = fullfile(path2project, 'derivatives', 'freesurfer',sprintf('%s', subject));

if strcmp(subject, 'sub-wlsubj049')
    roi_labels_lh = MRIread(fullfile(path2fs, 'surf', 'lh.ROIs_V1-3.mgz'));
    roi_labels_rh = MRIread(fullfile(path2fs, 'surf', 'rh.ROIs_V1-3.mgz'));
    roi_lh = squeeze(roi_labels_lh.vol);
    roi_rh = squeeze(roi_labels_rh.vol);
    roi_label = [roi_lh;roi_rh];
    labels = [(roi_label == 1)...
        (roi_label == 2)...
        (roi_label == 3)];
else
    roi_labels_lh = MRIread(fullfile(path2fs, 'surf', 'lh.ROIs_V1-IPS.mgz'));
    roi_labels_rh = MRIread(fullfile(path2fs, 'surf', 'rh.ROIs_V1-IPS.mgz'));
    roi_lh = squeeze(roi_labels_lh.vol);
    roi_rh = squeeze(roi_labels_rh.vol);
    if size(roi_rh, 2) > 1
        roi_label = [roi_lh';roi_rh'];
    else
        roi_label = [roi_lh;roi_rh];
    end
    labels = [(roi_label == 1)...
        (roi_label == 2)...
        (roi_label == 3)...
        (roi_label == 4)...
        (roi_label == 5)...
        (roi_label == 6)];
end