% This script extracts averaged pRF size estimates for a given
% eccentricitiy bin for each ROI and each subject. This analysis can be
% done either for the entire visual field, looking at Focal vs Distributed
% interactions independent of the position preference of the vertex; OR,
% for the specified quadrants that include the target matching pRFs. The
% desired parameters for these wedges can be set at the beginning of the
% script.

s0_attentionpRF;

eccen_limits = [1, 9];
binWidth     = linspace(eccen_limits(1),eccen_limits(2),9);
conditions   = 1:5;
focal_ind    = 1:4;
dist_ind     = 5;
polar_angle_limits    = {[45, 135]; [225, 315]; [135, 225]; [0, 45, 315, 360]};%
type = 'target_specific_distributed';
folderTag = 'prfFolder_2';
r2_tresh = 0.15; 
size_thresh = 1;

% preallocate the output
eccen_binned = zeros(length(subject_list), length(ROIs), length(conditions), length(binWidth));
size_binned = zeros(length(subject_list), length(ROIs), length(conditions), length(binWidth));
eccen_binned_base = zeros(length(subject_list), length(ROIs), length(conditions), length(binWidth));
size_binned_base = zeros(length(subject_list), length(ROIs), length(conditions), length(binWidth));
for subjInd = 1:length(subject_list)
    subject = subject_list(subjInd).name;
    disp(subject)

    % load ROIs:
    labels = attpRF_load_ROIs(path2project, subject);
    for roi_idx = 1:size(labels, 2)
        current_roi = labels(:,roi_idx);
        disp(ROIs{roi_idx})
        roi_indices = current_roi ~= 0;

        % for each focal attention condition, we will load the estimated
        % pRFs and extract the desired portions of the visual field
        % depending on the type of the analysis.
        for condition_idx = 1:length(conditions)
            prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('/%s/ses-%s/%s/%i/', subject, session, folderTag, conditions(condition_idx)));

            [eccentricity, angle] = attpRF_load_pRFs(prfFolder);

            sigma_lh = MRIread([prfFolder, 'lh.sigma.mgz']);
            sigma_rh = MRIread([prfFolder, 'rh.sigma.mgz']);
            sizefit = [sigma_lh.vol, sigma_rh.vol]';

            vexpl_lh = MRIread([prfFolder, 'lh.vexpl.mgz']);
            vexpl_rh = MRIread([prfFolder, 'rh.vexpl.mgz']);
            vexpl = [vexpl_lh.vol, vexpl_rh.vol]';

            switch type
                case 'target_specific_distributed'
                % get the target mask values for the whole brain (we don't
                % normally need
                fulldata_idx = current_roi == 0 | current_roi == 1;
                target_mask = attpRF_get_target_ROIs(fulldata_idx, eccentricity, angle, eccen_limits, polar_angle_limits);

                if condition_idx ~= dist_ind
                    indices = target_mask == condition_idx & vexpl > r2_tresh & current_roi ~= 0 & sizefit > size_thresh;
                    [eccen_binned(subjInd, roi_idx, condition_idx, :), size_binned(subjInd, roi_idx, condition_idx, :)] =...
                        bin_voxels_by_indices(eccentricity, sizefit, indices, binWidth);
                elseif condition_idx == dist_ind
                    for ii = 1:num_targets
                        indices_base_comp = target_mask == ii & vexpl > r2_tresh & current_roi ~= 0 & sizefit > size_thresh;
                        [eccen_binned_base(subjInd, roi_idx, ii, :), size_binned_base(subjInd, roi_idx, ii, :)] =...
                            bin_voxels_by_indices(eccentricity, sizefit, indices_base_comp, binWidth);
                    end
                end

                % save the binned data:
                eccen_binned(eccen_binned == 0) = NaN;
                size_binned(size_binned == 0) = NaN;
                eccen_binned_base(eccen_binned_base == 0) = NaN;
                size_binned_base(size_binned_base == 0) = NaN;
                data = cat(5, eccen_binned, size_binned, eccen_binned_base, size_binned_base);
                save(fullfile(path2project, 'derivatives/prf_size_data/binned_eccen_size_data.mat'), 'data', '-v7.3');
              
                case 'condition_specific' % assumes the attentional state will generalize across the visual field independent of
                    % where in space the cue directed the subject
                    indices = eccentricity < eccen_limits(2) & vexpl > r2_tresh & current_roi ~= 0 & sizefit > size_thresh;
                    [eccen_binned(subjInd, roi_idx, condition_idx, :), size_binned(subjInd, roi_idx, condition_idx, :)] =...
                        bin_voxels_by_indices(eccentricity, sizefit, indices, binWidth);


                case 'target_specific_attout'
                % get the target mask values for the whole brain (we don't
                % normally need this but let's use the same masking
                % function for coherence):
                fulldata_idx = current_roi == 0 | current_roi == 1;
                target_mask = attpRF_get_target_ROIs(fulldata_idx, eccentricity, angle, eccen_limits, polar_angle_limits);

                if condition_idx ~= dist_ind
                    % now the whole brain estimates are masked by the ROI
                    % labels and variance explained of the pRF model:
                    attin_indices = target_mask == condition_idx & vexpl > r2_tresh & current_roi ~= 0 & sizefit > size_thresh;
                    attout_nums = setdiff(1:4,condition_idx);
                    attout1_indices = target_mask == attout_nums(1) & vexpl > r2_tresh & current_roi ~= 0;
                    attout2_indices = target_mask == attout_nums(2) & vexpl > r2_tresh & current_roi ~= 0;
                    attout3_indices = target_mask == attout_nums(3) & vexpl > r2_tresh & current_roi ~= 0;
                    attout_indices = attout1_indices + attout2_indices + attout3_indices;
                    attout_indices = logical(attout_indices);
                    [eccen_binned_attin(subjInd, roi_idx, condition_idx, :), size_binned_attin(subjInd, roi_idx, condition_idx, :)] =...
                        bin_voxels_by_indices(eccentricity, sizefit, attin_indices, binWidth);
                    [eccen_binned_attout(subjInd, roi_idx, condition_idx, :), size_binned_attout(subjInd, roi_idx, condition_idx, :)] =...
                        bin_voxels_by_indices(eccentricity, sizefit, attout_indices, binWidth);
                end
            end
        end
    end
end


