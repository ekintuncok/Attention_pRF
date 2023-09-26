function roi_data = attpRF_extract_target_roi_amp(columns, props, sub, indRoi, currROI, betas, R2_GLM, eccen, angle, type)

roi_data = [];
roi_data(:,columns.subj_idx) = sub*ones(1,sum(currROI));
roi_data(:,columns.roi_idx)  = indRoi*ones(1,sum(currROI));
roi_data(:,columns.r2_idx)   = R2_GLM(currROI);

[target_mask] = attpRF_get_target_ROIs(currROI, eccen, angle, props.eccen_limits, props.polar_angle_limits);

switch type

    case 'averagedMS'
        roi_data(:,columns.cond_idx) = squeeze(mean(betas(currROI,:,:),2, 'omitnan'));

    case 'bar_overlaps'

        mappingStimLeft = [5:9, 35:38];
        mappingStimRight = [17:21, 35:38];
        mappingStimUpper = [11:14, 29:33];
        mappingStimLower = [11:14, 41:45];
        MS_overlappng_locs = cat(1, mappingStimUpper, mappingStimLower, mappingStimLeft, mappingStimRight);

        for cond = 1:size(MS_overlappng_locs,1) % loop through the focal attention conditions. This will return 8 data vectors, 2 for each attention condition.
            % For each focal attention condition, we have the estimated percent
            % BOLD change for the overlapping and nonoverlapping stimulus
            % positions. We need to do this now for the distributed attention
            % condition
            nonOvrlp_positions = setdiff(1:48, MS_overlappng_locs(cond,:));
            focal_grouped_betas(:,2*cond-1) = squeeze(mean(betas(currROI,MS_overlappng_locs(cond,:),cond),2, 'omitnan'));
            focal_grouped_betas(:,2*cond) = squeeze(mean(betas(currROI,nonOvrlp_positions,cond),2, 'omitnan'));
            distributed_grouped_betas(:,2*cond-1) = squeeze(mean(betas(currROI,MS_overlappng_locs(cond,:),5),2, 'omitnan'));
            distributed_grouped_betas(:,2*cond) = squeeze(mean(betas(currROI,nonOvrlp_positions,5),2, 'omitnan'));
        end

        betas_grouped_stim = cat(2, focal_grouped_betas, distributed_grouped_betas);
        roi_data(:,columns.cond_idx) = betas_grouped_stim;

    case 'MStimeseries'
        roi_data(:,columns.cond_idx) =  reshape(betas(currROI,:,:), [], size(betas(currROI,:,:),2)*size(betas(currROI,:,:),3));

    case {'averagedGabor', 'averagedblank'}
        roi_data(:,columns.cond_idx) = betas(currROI,:);
end

roi_data(:,columns.eccen_idx) = eccen(currROI);
roi_data(:,columns.angle_idx) = angle(currROI);
roi_data(:,columns.mask_idx) = target_mask;
