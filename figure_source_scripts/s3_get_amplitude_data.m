% Attention pRF project: runs multiple relevant scripts for a specific type
% of analysis using BOLD GLM results
s0_attentionpRF;

designFolder = 'main';
prf_folder_name = 'prfFolder_2';
cond_compare = {'Attend In', 'Distributed', 'Attend Out'};
target_output_dir = fullfile(path2project, 'derivatives','amplitude_data/');

% what kind of analysis?
analysis_type = input('Enter how you want to extract the amplitude data (see the main code body for options): ', 's');

[columns, props] = attpRF_ampdata_column_indices(analysis_type);
% "analysis_type" could be
%   1)'averagedMS' that returns attentional changes in
% cortical target ROIs by averaging the BOLD amplitude across mapping
% stimulus locations for different attentional cue conditions (See
% the data in Figure 6).
%   2)'MStimeseries' returns attentional changes in cortical target ROIs
% by plotting the BOLD amplitude as a function of mapping stimulus
% position for different attentional cue conditions (see Figure 5).
%   3) 'averagedBlank' fetches the baseline BOLD amplitude measured with
%   blank stimulus. This response is concatenated with averaged or
%   timeseries results to incorporate.
switch analysis_type
    case 'averagedMS'
        amplitude_data = attpRF_extract_betas(path2project, columns, props, ROIs, subject_list, designFolder, prf_folder_name, analysis_type);
        save([target_output_dir,'att_resp_averaged_mapst_pervoxel.mat'], 'amplitude_data', '-v7.3');
        target_indices = 1:num_targets;
        glm_r2_thresh = 5;

        subj_att_activity_per_loc = zeros(length(subject_list),length(ROIs), num_targets, length(cond_compare));
        subj_averaged_att_response = zeros(length(subject_list), length(ROIs), length(cond_compare)-1);
        for sub = 1:length(subject_list)
            for roi = 1:length(ROIs)
                for location = 1:num_targets
                    attend_out_idx = setdiff(columns.focal_idx, location+3);
                    mask = amplitude_data(:,columns.subj_idx) == sub & amplitude_data(:,columns.roi_idx) == roi & amplitude_data(:,columns.mask_idx) == target_indices(location) & amplitude_data(:, columns.r2_idx) > glm_r2_thresh;

                    attend_in_activity = mean(amplitude_data(mask, location+3));
                    attend_out_activity =  mean(mean(amplitude_data(mask, attend_out_idx), 'omitnan'), 'omitnan');
                    distributed_activity = mean(amplitude_data(mask, columns.dist_idx), 'omitnan');

                    % attend in:
                    subj_att_activity_per_loc(sub, roi, location, 1) = attend_in_activity;
                    % attend out:
                    subj_att_activity_per_loc(sub, roi, location, 2) = distributed_activity;
                    % attend dist:
                    subj_att_activity_per_loc(sub, roi, location, 3) = attend_out_activity;
                end
                % average across polar angle targets:
                temp_averaged = squeeze(mean(subj_att_activity_per_loc(sub, roi, :,:),3, 'omitnan'));
                % calculate the change from distributed to attend in and
                % out
                subj_averaged_att_response(sub, roi, 1) = (temp_averaged(1)-temp_averaged(2))/(temp_averaged(2));
                subj_averaged_att_response(sub, roi, 2) = (temp_averaged(3)-temp_averaged(2))/(temp_averaged(2));
            end
        end

        save([target_output_dir,'att_resp_averaged_mapst.mat'], 'subj_averaged_att_response', '-v7.3');

    case 'MStimeseries'
        disp(analysis_type);
        amplitude_data = attpRF_extract_betas(path2project, columns, props, ROIs, subject_list, designFolder, prf_folder_name, analysis_type);
        save([target_output_dir,'att_resp_pseudotimeseries.mat'], 'amplitude_data', '-v7.3');
        target_indices = 1:num_targets;
        num_data_pts = 49;

        subj_averaged_attention_activity = zeros(length(subject_list),length(ROIs), num_targets, length(cond_compare), num_data_pts);
        for sub = 1:length(subject_list)
            for roi = 1:length(ROIs)
                for location = 1:num_targets

                    mask = amplitude_data(:,columns.subj_idx) == sub & amplitude_data(:,columns.roi_idx) == roi & amplitude_data(:,columns.mask_idx) == target_indices(location);
                    % attend in:
                    attend_in_idx = (1+num_data_pts*(location-1):num_data_pts*location)+3;
                    attend_out_idx = setdiff(columns.focal_idx, attend_in_idx);
                    attend_out_sep = reshape(amplitude_data(mask, attend_out_idx), [], length(attend_out_idx)/3, 3);
                    subj_averaged_attention_activity(sub, roi, location, 1, :) = mean(amplitude_data(mask,attend_in_idx), 1, 'omitnan');
                    % distributed:
                    subj_averaged_attention_activity(sub, roi, location, 2, :) = mean(amplitude_data(mask, columns.dist_idx),1, 'omitnan');
                    % attend out:
                    subj_averaged_attention_activity(sub, roi, location, 3, :) = mean(mean(attend_out_sep, 3, 'omitnan'),1, 'omitnan');
                end
            end
        end
        save([target_output_dir,'att_resp_reorg_pseudotimeseries.mat'], 'subj_averaged_attention_activity', '-v7.3');

    case 'averagedblank'
        disp(analysis_type);
        amplitude_data = attpRF_extract_betas(path2project, columns, props, ROIs, subject_list, designFolder, prf_folder_name, analysis_type);
        save([target_output_dir, 'att_resp_blank.mat'], 'amplitude_data', '-v7.3');
end
