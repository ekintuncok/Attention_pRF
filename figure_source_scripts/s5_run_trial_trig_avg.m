s0_attentionpRF;
tta_TRs = 9;
trial_types = {'ms_overlap_1s', 'ms_overlap_2s', 'ms_nonoverlap_1s', 'ms_nonoverlap_2s', 'ms_null_1s', 'ms_null_2s'};

TTA = zeros(length(trial_types), length(subject_list), length(ROIs), num_targets, 3, tta_TRs+2);

ts_type_to_analyze = input('raw or predicted timeseries?', 's');
onset_event = 'gabor';

for trial_type_id = 1:length(trial_types)
    trial_type = trial_types{trial_type_id};
    disp(trial_type)

    switch trial_type
        case 'ms_overlap_1s'
            which_mapping_stim = MS_overlappng_locs;
            which_ms_dur = 1;
        case 'ms_overlap_2s'
            which_mapping_stim = MS_overlappng_locs;
            which_ms_dur = 2;
        case 'ms_nonoverlap_1s'
            which_mapping_stim = [setdiff(1:48, MS_overlappng_locs(1,:));...
                setdiff(1:48, MS_overlappng_locs(2,:));...
                setdiff(1:48, MS_overlappng_locs(3,:));...
                setdiff(1:48, MS_overlappng_locs(4,:))];
            which_ms_dur = 1;
        case 'ms_nonoverlap_2s'
            which_mapping_stim = [setdiff(1:48, MS_overlappng_locs(1,:));...
                setdiff(1:48, MS_overlappng_locs(2,:));...
                setdiff(1:48, MS_overlappng_locs(3,:));...
                setdiff(1:48, MS_overlappng_locs(4,:))];
            which_ms_dur = 2;
        case  'ms_null_1s'
            which_mapping_stim = repmat(49:52, 4, 1);
            which_ms_dur = 1;
        case 'ms_null_2s'
            which_mapping_stim = repmat(49:52, 4, 1);
            which_ms_dur = 2;
    end

    for subj_id = 1:length(subject_list)
        subject = subject_list(subj_id).name;
        disp(subject)
        disp(onset_event)

        load(fullfile(path2project, sprintf('derivatives/ROI_timeseries/%s_%s_ROI_timeseries.mat', subject, ts_type_to_analyze)))
        if strcmp(ts_type_to_analyze, 'predicted')
            subj_timeseries_data = subj_timeseries_prediction;
        end
        TR_information = attpRF_extract_TR_event(path2project, subject);

        bar_onsets_TR   = find(TR_information(:,1) == 1);
        gabor_onsets_TR = find(TR_information(:,1) == 2);
        precue_code     = TR_information(bar_onsets_TR,3);
        MS_code         = TR_information(bar_onsets_TR,2);
        MS_dur         = TR_information(bar_onsets_TR,4);

        for roi_id = 1:length(unique(subj_timeseries_data(:,2)))
            disp(ROIs{roi_id})
            for target = 1:num_targets

                mask = subj_timeseries_data(:,2) == roi_id & subj_timeseries_data(:,3) == target;
                curr_roi_data = subj_timeseries_data(mask,4:end);

                TTA_att_in = [];
                TTA_att_all = [];
                TTA_att_out = [];

                for stim_idx = 1:length(bar_onsets_TR)-3
                    if strcmp(onset_event, 'gabor')
                        % find the target Gabor onset, and systematically
                        % shift the onset back in time either 2 or 3TRs to
                        % shift the averaged responses
                        if gabor_onsets_TR(stim_idx) > 3
                            event_locked_response = curr_roi_data(:,gabor_onsets_TR(stim_idx)-3:gabor_onsets_TR(stim_idx)+tta_TRs+1-3);
                        else
                            event_locked_response = curr_roi_data(:,gabor_onsets_TR(stim_idx)-2:gabor_onsets_TR(stim_idx)+tta_TRs+1-2);
                        end
                    elseif strcmp(onset_event, 'trial')
                        % find the bar onset, and go 1 TR backward which is
                        % the Cue onset
                        event_locked_response = curr_roi_data(:,bar_onsets_TR(stim_idx)-1:bar_onsets_TR(stim_idx)+tta_TRs);
                    end

                    if ismember(MS_code(stim_idx), which_mapping_stim(target, :)) && MS_dur(stim_idx) == which_ms_dur % include trials that did not overlap w the target ROI
                        if precue_code(stim_idx) == target % in this trial, whether the cue was directing the subject to the current target

                            TTA_att_in = cat(3, TTA_att_in, event_locked_response);

                        elseif precue_code(stim_idx) == attend_neutral % in this trial, whether the cue was directing the subject to attend all

                            TTA_att_all = cat(3, TTA_att_all, event_locked_response);

                        elseif ismember(precue_code(stim_idx),setdiff(1:num_targets, target))

                            % in this trial, whether the cue was directing the
                            % subject to attend other targets

                            TTA_att_out = cat(3, TTA_att_out, event_locked_response);
                        end
                    end

                end
                TTA(trial_type_id, subj_id, roi_id, target, :, :) = [mean(mean(TTA_att_in, 3),1); mean(mean(TTA_att_all, 3),1); mean(mean(TTA_att_out, 3),1)];
            end
        end
    end
end

% First save the TTA separate for different trial types:
save(fullfile(path2project, sprintf('derivatives/trial_triggered_averages/trial_triggered_averages_2_%s_%s.mat', onset_event, ts_type_to_analyze)), 'TTA', '-v7.3');

% Then average across different mapping stimuli trials but keep the
% duration information in separate chunks: 
one_sec_tta = mean(TTA(1:2:5,:,:,:,:,:));
two_sec_tta = mean(TTA(2:2:6,:,:,:,:,:));
TTA = cat(1, one_sec_tta, two_sec_tta);
save(fullfile(path2project, sprintf('derivatives/trial_triggered_averages/all_trial_triggered_averages_2_%s_%s.mat', onset_event, ts_type_to_analyze)), 'TTA', '-v7.3');

