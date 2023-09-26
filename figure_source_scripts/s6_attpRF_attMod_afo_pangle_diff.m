s0_attentionpRF;

% load the data:
load(fullfile(path2project, 'derivatives','amplitude_data','att_resp_averagedMS.mat'))
amp_averagedMS = gain_data;
load(fullfile(path2project, 'derivatives','amplitude_data','att_resp_Null.mat'))
amp_null = gain_data;
data = (amp_averagedMS + amp_null)/2;

% define the parameters:
[columns, props] = attpRF_ampdata_column_indices('averagedMS');

fit_func = 'diff_von_mises';
pa_distance_bins = -180:20:180;
output       = attpRF_fit_vonMises_to_attSignal(data, columns, props.target_angle_location, props.eccen_limits, pa_distance_bins, fit_func);

nanmedian(output.rsq);

for roi = 1:length(ROIs)
    dat = output.rsq(:, roi);
    [lw_ci(roi, 1), up_ci(roi, 1)] = calculate_bootstrapped_confidence_interval(dat, 'mdn');
end


