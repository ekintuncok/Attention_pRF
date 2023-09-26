% check the bar duration effects:
s0_attentionpRF;
data_type = 'raw';
onset_type = {'_2_trial', '_2_gabor'};
num_fits = 1000;
num_comps = 4; % rising and falling for 1 sec and 2 sec bars
num_params = 2; % slope and t50
recon_data_all = cell(length(ROIs), num_fits);
params = zeros(length(ROIs), num_fits, num_comps, num_params);
rsquare = zeros(length(ROIs), num_fits,num_comps);
latency_drop_val = 0.1;
diff_latency = zeros(length(onset_type), length(ROIs), num_fits, num_comps/2);
comp_id_1 = 1;
comp_id_2 = 3;

% Load the data"
load(fullfile(path2project, sprintf('derivatives/trial_triggered_averages/all_trial_triggered_averages%s_%s.mat', onset_type{1}, data_type)));
resp_triallocked = TTA;
clear TTA
load(fullfile(path2project, sprintf('derivatives/trial_triggered_averages/all_trial_triggered_averages%s_%s.mat', onset_type{2}, data_type)));
resp_targetlocked = TTA;
clear TTA

for roi = 1:length(ROIs)

    if roi == 4
        % Subject 1 does not have hV4, V3AB or LO1, so omit them:
        resp_triallocked(:,1,:,:,:,:) = [];
        resp_targetlocked(:,1,:,:,:,:) = [];
        sbj_n = 7;
    elseif roi == 5 || roi == 6
        sbj_n = 7;
    else
        sbj_n = 8;
    end
    event_trig_resp = zeros(num_comps, sbj_n, 3, 11);

    for iter = 1:num_fits
        fprintf('%s, iter = %i\n', ROIs{roi}, iter)
        % sample subject IDs with replacement to create a sample for
        % this given iteration of fitting:
        rand_subj_ids = datasample(1:sbj_n,sbj_n);

        % average the data across cortical target masks (4 polar angle
        % locations)
        trial_locked_data_1s = squeeze(mean(resp_triallocked(1, :, roi, :, :, :), 4, 'omitnan'));
        trial_locked_data_2s = squeeze(mean(resp_triallocked(2, :, roi, :, :, :), 4, 'omitnan'));

        target_locked_data_1s = squeeze(mean(resp_targetlocked(1, :, roi, :, :, :), 4, 'omitnan'));
        target_locked_data_2s = squeeze(mean(resp_targetlocked(2, :, roi, :, :, :), 4, 'omitnan'));

        % subsample the data with the randomized subject IDs:
        trl_data_to_fit_1s = trial_locked_data_1s(rand_subj_ids, :, :);
        trl_data_to_fit_2s = trial_locked_data_2s(rand_subj_ids, :, :);

        trg_data_to_fit_1s = target_locked_data_1s(rand_subj_ids, :, :);
        trg_data_to_fit_2s = target_locked_data_2s(rand_subj_ids, :, :);

        event_trig_resp(1,:,:,:) = trl_data_to_fit_1s;
        event_trig_resp(2,:,:,:) = trl_data_to_fit_2s;
        event_trig_resp(3,:,:,:) = trg_data_to_fit_1s;
        event_trig_resp(4,:,:,:) = trg_data_to_fit_2s;

        for event_id = 1:length(onset_type)
            data_to_fit_1s = squeeze(event_trig_resp(2*event_id - 1, :, :,:));
            data_to_fit_2s = squeeze(event_trig_resp(2*event_id, :, :,:));

            curr_sub_1s = squeeze(mean(data_to_fit_1s,1, 'omitnan'));
            curr_sub_2s = squeeze(mean(data_to_fit_2s,1, 'omitnan'));

            att_modulation_1s = (curr_sub_1s(comp_id_1,:) - curr_sub_1s(comp_id_2,:));
            att_modulation_2s = (curr_sub_2s(comp_id_1,:) - curr_sub_2s(comp_id_2,:));
            data_tf = cell(1, num_comps);

            % fit the data with a logistic function:
            % normalize by the min-max to set the lowest value to 0, and
            % the highest value to 1.
            one_s_tf = (att_modulation_1s - min(att_modulation_1s))/(max(att_modulation_1s)- min(att_modulation_1s));
            two_s_tf = (att_modulation_2s - min(att_modulation_2s))/(max(att_modulation_2s)- min(att_modulation_2s));

            % split the rising and falling edges of the response curve by
            % finding the maximum value, and dividing the responses into
            % two chunks as before (rising to the max) and after (falling
            % from the max
            [~, id_onesec] = max(one_s_tf);[~, id_twosec] = max(two_s_tf);
            data_tf{1} = one_s_tf(1:id_onesec);
            data_tf{2} = two_s_tf(1:id_twosec);

            data_tf{3} = one_s_tf(id_onesec:end);
            data_tf{4} = two_s_tf(id_twosec:end);

            time_to_peak{1} = 1:id_onesec;
            time_to_peak{2} = 1:id_twosec;
            time_to_peak{3} = id_onesec:length(one_s_tf);
            time_to_peak{4} = id_twosec:length(two_s_tf);

            % fit the data with a logistic function, get the estimated
            % params, reconstructed curve, and Rsquare!
            [params(roi, iter, :, :), recon_data_all{roi, iter}, rsquare(roi,iter, :)] = fit_logistic_func(data_tf);

            x_10 = zeros(length(ROIs),iter, num_comps);
            for fit_data = 1:num_comps
                crr_fit =  recon_data_all{roi, iter}{fit_data};
                if ~isnan(crr_fit(1))
                    t = time_to_peak{fit_data};
                    if fit_data < 3
                        y_10 = max(crr_fit) * latency_drop_val;
                    else
                        y_10 = max(crr_fit) - max(crr_fit) * latency_drop_val;
                    end
                    syms x
                    x_10(roi, iter, fit_data) = double(vpasolve(1./(1 + exp(-params(roi, iter, fit_data, 1).*(x-params(roi, iter, fit_data, 2)))) == y_10, x));
                    if fit_data > 2
                        x_10(roi, iter, fit_data) =  x_10(roi, iter, fit_data) + t(1); % for the falling time, we add the time to peak to lock the falling time
                        % estimate to the event of interest
                    end
                else
                    x_10(roi, iter, fit_data) = NaN;
                end
            end

            x_10(x_10>20)= NaN; % get rid of unreasonable estimates not to inflate the mean
            diff_latency(event_id, roi, iter, 1) =  x_10(roi, iter, 2) - x_10(roi, iter, 1);
            diff_latency(event_id, roi, iter, 2) =  x_10(roi, iter, 4) - x_10(roi, iter, 3);
        end
    end
end

save(fullfile(path2project,'derivatives/trial_triggered_averages/latency_of_attenional_modulation.mat'), 'diff_latency', '-v7.3')
