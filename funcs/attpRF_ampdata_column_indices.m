function [columns, props] = attpRF_ampdata_column_indices(type)

columns.subj_idx = 1;
columns.roi_idx = 2;
columns.r2_idx = 3;

props.polar_angle_limits    = {[60, 120]; [240, 300]; [150, 210]; [0, 30, 330, 360]};

props.eccen_limits          = [4, 8];
props.target_angle_location = [90, 270, 180, 0];
props.session ='nyu3t99';

switch type
    case 'MStimeseries'

        num_locs = 49;

        columns.focal_idx = columns.r2_idx+1:(columns.r2_idx+num_locs*4);
        columns.dist_idx = columns.focal_idx(end)+1:columns.focal_idx(end)+num_locs;
        columns.cond_idx = [columns.focal_idx, columns.dist_idx];
        columns.eccen_idx = columns.cond_idx(end)+1;
        columns.angle_idx = columns.eccen_idx+1;
        columns.mask_idx = columns.angle_idx+1;

    case 'bar_overlaps'

        num_locs = 2;
        columns.focal_idx = columns.r2_idx+1:(columns.r2_idx+num_locs*4);
        columns.dist_idx = columns.focal_idx(end)+1:columns.focal_idx(end)+num_locs*4;
        columns.cond_idx = [columns.focal_idx, columns.dist_idx];
        columns.eccen_idx = columns.cond_idx(end)+1;
        columns.angle_idx = columns.eccen_idx+1;
        columns.mask_idx = columns.angle_idx+1;


    case {'averagedGabor', 'averagedMS', 'averagedblank'}

        columns.focal_idx = 4:7;
        columns.dist_idx = 8;
        columns.cond_idx = [columns.focal_idx, columns.dist_idx];
        columns.eccen_idx = 9;
        columns.angle_idx = 10;
        columns.mask_idx = 11;

    case 'prf_shift_directional_graphs'
        props.pangle_bins = 0:45:360;
        props.eccen_windows = 0.5:1:6.25;
        columns.subj_col = 1;
        columns.roi_col = 2;
        columns.att_up_col = [3, 4, 5];
        columns.att_down_col = [6, 7, 8];
        columns.att_left_col = [9, 10, 11];
        columns.att_right_col = [12, 13, 14];
        columns.att_dist_col = [15, 16, 17];

        columns.base_v_eccen = 18;
        columns.base_v_angle = 19;
        columns.base_h_eccen = 20;
        columns.base_h_angle = 21;
        columns.base_bin_v_eccen = 22;
        columns.base_bin_v_angle = 23;
        columns.base_bin_h_eccen = 24;
        columns.base_bin_h_angle = 25;

end