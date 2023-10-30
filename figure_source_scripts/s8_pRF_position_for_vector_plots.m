s0_attentionpRF;
data = [];

% column information (for future purposes):
type = 'prf_shift_directional_graphs';
[columns, ~] = attpRF_ampdata_column_indices(type);
type = 'cart';

for sub = 1:length(subject_list)
    subject = subject_list(sub).name;
    disp(subject)
    labels = attpRF_load_ROIs(path2project, subject);
    retinotopy_conditions = {'1', '2', '3', '4', '5'};
    subject_data = [];
    for roi = 1:size(labels,2)
        currROI = labels(:,roi);
        indices = currROI ~= 0;
        disp(ROIs{roi})
        roi_data = zeros(sum(indices), 22);
        roi_data(:,columns.subj_col) = sub;
        roi_data(:,columns.roi_col) = roi;
        for ret_data_idx = 1:length(retinotopy_conditions)
            prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
                sprintf('ses-%s',session), 'prfFolder_2', sprintf('%s/',retinotopy_conditions{ret_data_idx}));

            [eccen, angle] = attpRF_load_pRFs(prfFolder, type);

            vexpl_lh = MRIread(fullfile(prfFolder, 'lh.vexpl.mgz'));
            vexpl_rh = MRIread(fullfile(prfFolder, 'rh.vexpl.mgz'));
            vexpl = [vexpl_lh.vol vexpl_rh.vol]';

            roi_data(:,3*ret_data_idx) = eccen(indices);
            roi_data(:,3*ret_data_idx+1) = angle(indices);
            roi_data(:,3*ret_data_idx+2) = vexpl(indices);

        end
        subject_data = cat(1,subject_data, roi_data);
    end
    data = cat(1,data, subject_data);
end

save(fullfile(path2project, 'derivatives/prf_shift_data/prf_centers_for_vector_figs.mat'), 'data', '-v7.3');

