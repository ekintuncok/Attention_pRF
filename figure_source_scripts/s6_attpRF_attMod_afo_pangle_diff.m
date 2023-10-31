s0_attentionpRF;

% load the data:
load(fullfile(path2project, 'derivatives','amplitude_data','att_resp_averaged_mapst_pervoxel.mat'))
amp_averagedMS = amplitude_data;
load(fullfile(path2project, 'derivatives','amplitude_data','att_resp_blank.mat'))
amp_null = amplitude_data;
data = (amp_averagedMS + amp_null)/2;

% define the parameters:
[columns, props] = attpRF_ampdata_column_indices('averagedMS');
fit_func = 'diff_von_mises';
pa_distance_bins = -180:20:180;
output       = attpRF_fit_vonMises_to_attSignal(data, columns, props.target_angle_location, props.eccen_limits, pa_distance_bins, fit_func);

target_output_dir = fullfile(path2project, 'derivatives','amplitude_data/');
save([target_output_dir,'vonmises_output.mat'], 'output', '-v7.3');
