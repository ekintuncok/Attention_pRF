function [target_mask] = attpRF_get_target_ROIs(indices, eccen, angle, eccen_limits, polar_angle_limits)
 
eccen_lower_limit = eccen_limits(1);
eccen_upper_limit = eccen_limits(2);

eccen_indices = eccen(indices) > eccen_lower_limit & eccen(indices) < eccen_upper_limit;

uvm_indices = (angle(indices)  > polar_angle_limits{1}(1) & angle(indices) < polar_angle_limits{1}(2));
lvm_indices = (angle(indices) > polar_angle_limits{2}(1) & angle(indices) < polar_angle_limits{2}(2));
lhm_indices = (angle(indices) > polar_angle_limits{3}(1) & angle(indices) < polar_angle_limits{3}(2));
rhm_indices = (angle(indices) > polar_angle_limits{4}(1) & angle(indices) < polar_angle_limits{4}(2)) |...
    (angle(indices) > polar_angle_limits{4}(3) & angle(indices) < polar_angle_limits{4}(4));

target_mask = zeros(length(find(indices == 1)), 1);
target_mask(uvm_indices&eccen_indices,1) = 1;
target_mask(lvm_indices&eccen_indices,1) = 2;
target_mask(lhm_indices&eccen_indices,1) = 3;
target_mask(rhm_indices&eccen_indices,1) = 4;
