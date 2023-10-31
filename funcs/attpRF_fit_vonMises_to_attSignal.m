function [output] = attpRF_fit_vonMises_to_attSignal(gain_data, columns, target_angle_location, eccen_limits, pa_distance_bins, fit_func)

s0_attentionpRF;
eccen_indices = gain_data(:,columns.eccen_idx) > eccen_limits(1) & gain_data(:,columns.eccen_idx) < eccen_limits(2);
amplitude_data = gain_data(eccen_indices,:);

X = (pa_distance_bins);
if strcmp(fit_func, 'von_mises')
    num_params = 4;
else
    num_params = 6;
end

sbj_n = 8;
num_iter = 1000;
% Preallocate:
att_resp_all_bars = zeros(num_iter, length(ROIs), length(pa_distance_bins));
est_params = zeros(num_iter, length(ROIs), num_params);
recon_data = zeros(num_iter, length(ROIs), length(X));
rsq = zeros(num_iter,length(ROIs));
for iter = 1:num_iter
    fprintf(">> Iteration number : %i\n", iter)
    rand_subj_ids = datasample(1:sbj_n,sbj_n);
    sampled_data = [];
    for sub_to_samp = 1:length(rand_subj_ids)
        curr_sampled_data = amplitude_data(amplitude_data(:,columns.subj_idx) == rand_subj_ids(sub_to_samp),:);
        sampled_data = [sampled_data; curr_sampled_data];
    end
    num_roi = unique(sampled_data(:, columns.roi_idx));
    for roi = 1:length(num_roi)
        indices =  sampled_data(:,columns.roi_idx) == roi;
        roi_gain    = sampled_data(indices,:);
        polar_angle = sampled_data(indices,columns.angle_idx);
        [att_resp_all_bars(iter, roi, :), ~] = attpRF_get_binned_amplitude_change(roi_gain, polar_angle, target_angle_location, pa_distance_bins);
    end
    
    Y = squeeze(att_resp_all_bars(iter,:,:));
    Y(find(sum(Y,2) == 0),:) = NaN; % subj049 only has 3 ROIS drawn. This is to deal with that.

    [est_params(iter,:,:), recon_data(iter,:,:), rsq(iter,:)] = fit_vm(fit_func, X, Y);
    fwhm(iter,:,:) = calculate_fwhm(X, Y);
    [x_intercept1(iter,:), x_intercept2(iter,:)] = calculate_x_intercepts(fit_func, squeeze(est_params(iter,:,:)));

end

output.att_resp_all_bars = att_resp_all_bars;
output.est_params = est_params;
output.recon_data = recon_data;
output.rsq = rsq;
output.fwhm = squeeze(fwhm);
output.angle_intercept = abs(x_intercept2) + abs(x_intercept1);



