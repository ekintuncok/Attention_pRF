function gain_data = attpRF_extract_betas(path2project, columns, props, ROIs, subject_list, designFolder, prf_folder_name, analysis_type)

gain_data = [];

for sub = 1:length(subject_list)
    thresholded_betas = [];
    subject = subject_list(sub).name;
    disp(subject)
    GLMfolder         = sprintf('%sderivatives/GLMdenoise/%s/%s/ses-%s/', path2project, designFolder, subject, props.session);
    load([GLMfolder sprintf('%s_ses-%s_%s_results.mat', subject, props.session, designFolder)]);% this loads 'betas' and 'R2'

    switch analysis_type
        case {'averagedMS','bar_overlaps','MStimeseries'}
            for idx = 1:length(betas)-2
                thresholded_betas(:,:,idx) = squeeze(betas{idx});
            end
            thresholded_betas(:,49,:) = squeeze(betas{6}); % blank trial estimates
        case 'averagedGabor'
            thresholded_betas = squeeze(betas{7});
        case 'averagedblank'
            thresholded_betas = squeeze(betas{6});
    end

    R2_GLM=R2';

    % load averaged pRF estimates:
    prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
        sprintf('ses-%s',props.session), sprintf('%s', prf_folder_name), 'avg/');

    [eccen, angle] = attpRF_load_pRFs(prfFolder);

    % load ROI information:
    labels = attpRF_load_ROIs(path2project, subject);

    % extract beta weights:
    subject_gain_data = [];
    for roi_idx = 1:size(labels,2)
        disp(ROIs{roi_idx})
        roi_indices = labels(:,roi_idx);
        roi_gain_data = attpRF_extract_target_roi_amp(columns, props, sub, roi_idx, roi_indices, thresholded_betas, R2_GLM, eccen, angle, analysis_type);
        subject_gain_data = cat(1,subject_gain_data, roi_gain_data);
    end
    gain_data = cat(1, gain_data, subject_gain_data);
end


