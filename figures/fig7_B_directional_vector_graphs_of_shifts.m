s0_attentionpRF;
[columns, props] = attpRF_ampdata_column_indices('prf_shift_directional_graphs');

try
    load(fullfile(path2project, 'derivatives/prf_shift_data/prf_centers_for_vector_figs.mat'));
catch ME
    s8_pRF_position_for_vector_plots;
end

% set the threshold:
R2_thresh = 0.25;
data(data(:,columns.roi_col) == 6,columns.roi_col) = 5; % for averaging purposes (across V3AB and LO1)

ROIs = {'V1','V2','V3', 'hV4','V3AB - LO1'};

thresholded_vertex_indices = data(:,columns.att_up_col(3)) > R2_thresh &  data(:,columns.att_down_col(3)) > R2_thresh...
    &  data(:,columns.att_left_col(3)) > R2_thresh &  data(:,columns.att_right_col(3)) >R2_thresh & data(:,columns.att_dist_col(3)) >R2_thresh;

% get the thresholded dataset:
data_to_bin = data(thresholded_vertex_indices,:);

% average the eccentricity and PA estimates of thresholded vertices across
% horizontal and vertical attention conditions to create the bins in Klein
% way:

% assign bin numbers to the averaged position estimates:
base_type = input('distributed (supp figure) or directional (main manuscript figure):', 's');

if strcmp(base_type, 'distributed')
    props.eccen_windows = 0.5:1.5:6.25;
end
avg_type = 'cart';

% Create a bin base to assess the directional shifts. We can either use the
% average of two ends of the direction (ie, (left+right)/2); or the
% distributed attention estimatesc
switch base_type

    case 'directional'
        data_to_bin(:,columns.base_v_x) = (data_to_bin(:,columns.att_up_col(1)) + data_to_bin(:,columns.att_down_col(1)))/2;
        data_to_bin(:,columns.base_h_x) = (data_to_bin(:,columns.att_left_col(1)) + data_to_bin(:,columns.att_right_col(1)))/2;

        data_to_bin(:,columns.base_v_y) = (data_to_bin(:,columns.att_up_col(2)) + data_to_bin(:,columns.att_down_col(2)))/2;
        data_to_bin(:,columns.base_h_y) = (data_to_bin(:,columns.att_left_col(2)) + data_to_bin(:,columns.att_right_col(2)))/2;

    case 'distributed'

        data_to_bin(:,columns.base_v_x) = (data_to_bin(:,columns.att_dist_col(1)) + data_to_bin(:,columns.att_dist_col(1)))/2;
        data_to_bin(:,columns.base_h_x) = (data_to_bin(:,columns.att_dist_col(1)) + data_to_bin(:,columns.att_dist_col(1)))/2;

        data_to_bin(:,columns.base_v_y) = (data_to_bin(:,columns.att_dist_col(2)) + data_to_bin(:,columns.att_dist_col(2)))/2;
        data_to_bin(:,columns.base_h_y) = (data_to_bin(:,columns.att_dist_col(2)) + data_to_bin(:,columns.att_dist_col(2)))/2;
end

% The averaged based above is calculated using the cartesian coordinate
% values of pRFs. Here we're going to convert from cart to polar
% coordinates to assign each vertex to a bin defined in polar coordinates:
[polar_coords(:,1), polar_coords(:,2)] = cart2pol(data_to_bin(:,columns.base_v_x), data_to_bin(:,columns.base_v_y));
polar_coords(:,1) = rad2deg(polar_coords(:,1));

[polar_coords(:,3), polar_coords(:,4)] = cart2pol(data_to_bin(:,columns.base_h_x ), data_to_bin(:,columns.base_h_y));
polar_coords(:,3) = rad2deg(polar_coords(:,3));


% now take the polar coordinates and assign the corresponding eccentricity
% and polar angle bin to each vertex:
for eccen_idx = 1:length(props.eccen_windows)-1
    eccen_indices_v = find(polar_coords(:, 2) > props.eccen_windows(eccen_idx) & polar_coords(:, 2) < props.eccen_windows(eccen_idx+1));
    eccen_indices_h = find(polar_coords(:, 4) > props.eccen_windows(eccen_idx) & polar_coords(:, 4) < props.eccen_windows(eccen_idx+1));
    % assign the bin number:
    data_to_bin(eccen_indices_v, columns.base_bin_v_eccen) = eccen_idx;
    data_to_bin(eccen_indices_h, columns.base_bin_h_eccen) = eccen_idx;
end

if props.pangle_bins(1) == 0

    for angle_idx = 1:length(props.pangle_bins)-1
        angle_indices_v = find(polar_coords(:, 1) > props.pangle_bins(angle_idx) & polar_coords(:, 1) < props.pangle_bins(angle_idx+1));
        angle_indices_h = find(polar_coords(:, 3) > props.pangle_bins(angle_idx) & polar_coords(:, 3) < props.pangle_bins(angle_idx+1));
        data_to_bin(angle_indices_v, columns.base_bin_v_angle) = angle_idx;
        data_to_bin(angle_indices_h, columns.base_bin_h_angle) = angle_idx;
    end

else

    for angle_idx = 1:length(props.pangle_bins)-1
        if angle_idx == 8
            angle_indices_v = [find(polar_coords(:, 1) > props.pangle_bins(angle_idx) & polar_coords(:, 1) < 360) ; ...
                find(polar_coords(:, 1) < props.pangle_bins(angle_idx+1) & polar_coords(:, 1) > 0)];
            angle_indices_h = [find(polar_coords(:, 3) > props.pangle_bins(angle_idx) & polar_coords(:, 3) < 360) ; ...
                find(polar_coords(:, 3) < props.pangle_bins(angle_idx+1) & polar_coords(:, 3) > 0)];
        else
            angle_indices_v = find(polar_coords(:, 1) > props.pangle_bins(angle_idx) & polar_coords(:, 1) < props.pangle_bins(angle_idx+1));
            angle_indices_h = find(polar_coords(:, 3) > props.pangle_bins(angle_idx) & polar_coords(:, 3) < props.pangle_bins(angle_idx+1));
        end
        data_to_bin(angle_indices_v, columns.base_bin_v_angle) = angle_idx;
        data_to_bin(angle_indices_h, columns.base_bin_h_angle) = angle_idx;
    end

end
% get rid of the vertices that fell outside of the desired bins in either
% horizontal or vertical condition:
bin_indices_all = data_to_bin(:,columns.base_bin_v_eccen:columns.base_bin_h_angle) ~= 0; smmd_bin = sum(bin_indices_all, 2);
bin_indices_final = smmd_bin == 4;
data_to_plot = data_to_bin(bin_indices_final,:);

th = 0:pi/50:2*pi;
xunit = zeros(length(props.eccen_windows)-1, length(th));
yunit = zeros(length(props.eccen_windows)-1, length(th));

for ecc_idx = 1:length(props.eccen_windows)
    xunit(ecc_idx,:) = props.eccen_windows(ecc_idx) * cos(th);
    yunit(ecc_idx,:) = props.eccen_windows(ecc_idx) * sin(th);
end

shift_dirs = {'Horizontal','Vertical'};
left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;
x_line_dat = -8:8;

for shift_dir = 1:length(shift_dirs)
    if shift_dir == 1
        att_cond_indices = [columns.att_left_col(1), columns.att_left_col(2), columns.att_right_col(1), columns.att_right_col(2)];
        plot_col = 'k';
        base_x_colidx = columns.base_h_x;
        base_y_colidx = columns.base_h_y;
        bin_base_x_colidx = columns.base_bin_h_eccen;
        bin_base_y_colidx = columns.base_bin_h_angle;
        target_coords = [-6, 0; 6,0];
        cmap = [left_roi_cmap;right_roi_cmap];
    else
        att_cond_indices = [columns.att_up_col(1), columns.att_up_col(2), columns.att_down_col(1), columns.att_down_col(2)];
        plot_col = 'k';
        base_x_colidx = columns.base_v_x;
        base_y_colidx = columns.base_v_y;
        bin_base_x_colidx = columns.base_bin_v_eccen;
        bin_base_y_colidx = columns.base_bin_v_angle;
        target_coords = [0, 6; 0, -6];
        cmap = [upper_roi_cmap;lower_roi_cmap];
    end
    ff = figure;
    for roi = 1:length(ROIs)
        subplot(1, 5, roi)
        roi_mask = data_to_plot(:,columns.roi_col)==roi;
        current_roi_data = data_to_plot(roi_mask,:);

        % draw isoeccentric lines at the bin edges:
        plot(xunit', yunit', 'linewidth',1,'color',[127 127 127]/255);
        ylim([-1*props.eccen_windows(end)-1.2,props.eccen_windows(end)+1.2])
        xlim([-1*props.eccen_windows(end)-1.2,props.eccen_windows(end)+1.2])
        hold on
        yline(0, 'color',[127 127 127]/255)
        hold on
        xline(0,  'color',[127 127 127]/255)
        hold on
        % draw the isoangle lines at the bin edges:
        plot(x_line_dat, x_line_dat, 'color',[127 127 127]/255)
        hold on
        plot(-1*x_line_dat, x_line_dat, 'color',[127 127 127]/255)
        hold on
        % draw the targets:
        plot(target_coords(1,1), target_coords(1,2), 'o',  'MarkerFaceColor', cmap(1,:),'MarkerEdgeColor', cmap(1,:), 'MarkerSize', 15)
        hold on
        plot(target_coords(2,1), target_coords(2,2), 'o', 'MarkerFaceColor', cmap(2,:),'MarkerEdgeColor', cmap(2,:),'MarkerSize', 15)
        hold on


        % Go through each polar angle and eccentricity bin as defined
        % above, and plot the direction of change in the center value for
        % the corresponding attentional axis:
        for pangle_bin = 1:length(props.pangle_bins)-1
            for eccen_bin = 1:length(props.eccen_windows)-1
                % the center bin value:
                bin_indices = current_roi_data(:,bin_base_x_colidx)==eccen_bin & current_roi_data(:,bin_base_y_colidx)==pangle_bin;
                % curr_bin_base(1) = mean(current_roi_data(bin_indices, base_x_colidx),'omitnan');
                % curr_bin_base(2) = mean(current_roi_data(bin_indices, base_y_colidx), 'omitnan');
                % % plot the averaged bin base:
                % plot(curr_bin_base(1), curr_bin_base(2), 'o', 'color', plot_col,'markersize', 5, 'markeredgecolor', 'k')
                % hold on

                % now plot the change in the center for two attention
                % conditions (direction 1 refers to either LEFT (for
                % horizontal plotting) or UP (for vertical plotting)
                attend_dir1_bin_pos(1) = mean(current_roi_data(bin_indices, att_cond_indices(1)), 'omitnan');
                attend_dir1_bin_pos(2) = mean(current_roi_data(bin_indices, att_cond_indices(2)),'omitnan');

                attend_dir2_bin_pos(1) = mean(current_roi_data(bin_indices, att_cond_indices(3)), 'omitnan');
                attend_dir2_bin_pos(2) = mean(current_roi_data(bin_indices, att_cond_indices(4)),'omitnan');

                % color code the shift direction vector based on the
                % expected axis movement:
                % if  sqrt((attend_dir1_bin_pos(1) - target_coords(1,1)).^2 + (attend_dir1_bin_pos(2) - target_coords(1,2)).^2) < sqrt((attend_dir2_bin_pos(1) - target_coords(1,1)).^2 + (attend_dir2_bin_pos(2) - target_coords(1,2)).^2) && ...
                %     sqrt((attend_dir2_bin_pos(1) - target_coords(2,1)).^2 + (attend_dir2_bin_pos(2) - target_coords(2,2)).^2) < sqrt((attend_dir1_bin_pos(1) - target_coords(2,1)).^2 + (attend_dir1_bin_pos(2) - target_coords(2,2)).^2)
                %     vector_col = [0,0,0];
                % else
                %     vector_col = [189,0,38]/255;
                % end

                if shift_dir == 1 % horizontal axis
                    if attend_dir1_bin_pos(1) < attend_dir2_bin_pos(1)
                        vector_col = [0,0,0];
                    else
                        vector_col = [189,0,38]/255;
                    end
                else
                    if attend_dir1_bin_pos(2) > attend_dir2_bin_pos(2) % vertical
                        vector_col = [0,0,0];
                    else
                        vector_col = [189,0,38]/255;
                    end
                end

                % finally plot the vector:
                plot(attend_dir1_bin_pos(1), attend_dir1_bin_pos(2), 'o', 'MarkerFaceColor', cmap(1,:),'MarkerEdgeColor', cmap(1,:), 'MarkerSize', 3)
                hold on
                plot(attend_dir2_bin_pos(1), attend_dir2_bin_pos(2), 'o','MarkerFaceColor',  cmap(2,:),'MarkerEdgeColor', cmap(2,:), 'MarkerSize', 3)
                hold on
                quiver(attend_dir1_bin_pos(1), attend_dir1_bin_pos(2), attend_dir2_bin_pos(1)-attend_dir1_bin_pos(1), attend_dir2_bin_pos(2)-attend_dir1_bin_pos(2),...
                    'off','linewidth',1.75,'color',vector_col)
                axis square
                set(gcf,'color','w')
                set(gca,'FontName','Roboto','FontSize',18)
                set(gca,'TickLength', [0.008 0.008], 'LineWidth', 1)
                title(ROIs{roi})
                if roi == 1
                    ylabel('Y Position (deg)')
                    xlabel('X Position (deg)')
                end
                set(gcf,'position',[0,0,1400,400])
            end
        end
    end
end
