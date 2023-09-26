function [binned_activity1, binned_activity2] = attpRF_get_binned_amplitude_change(roi_gain, polar_angle, target_angle_location, pa_distance_bins)

[columns, ~] = attpRF_ampdata_column_indices('averagedMS');
averaged_att_response_bin  = zeros(length(target_angle_location), length(pa_distance_bins));

for ii = 1:length(target_angle_location)
    
    % bin the data for the given stimulus location:

    distance_in_polar_angle = fix_deg(polar_angle - target_angle_location(ii));
    [bin_indices, ~] = discretize(distance_in_polar_angle, pa_distance_bins);
    
    for bin_id = 1:length(pa_distance_bins)
        bin_indices_tp = bin_indices == bin_id;
        focal_att_response = mean(roi_gain(bin_indices_tp,columns.focal_idx(ii)), 'omitnan');
        dist_att_response = mean(roi_gain(bin_indices_tp,columns.dist_idx), 'omitnan');
        averaged_att_response_bin(ii, bin_id) = (focal_att_response - dist_att_response);
    end

end

binned_activity1 = mean(averaged_att_response_bin, 1, 'omitnan');
binned_activity1(end) = binned_activity1(1);
binned_activity2 = NaN(1, length(binned_activity1));


