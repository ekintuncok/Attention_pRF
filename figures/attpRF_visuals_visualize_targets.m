% plot epsilon
s0_attentionpRF;
left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;
cmap_targ = [upper_roi_cmap;lower_roi_cmap;left_roi_cmap;right_roi_cmap; [0,0,0]];
target_coords = [0, 6; 0, -6; -6, 0; 6,0];
grid_lim= 12;
% circle at the target eccentricity
th = 0:pi/50:2*pi;
xunit = grid_lim/2 * cos(th) + 0;
yunit = grid_lim/2 * sin(th) + 0;

xunit2 = grid_lim * cos(th) + 0;
yunit2 = grid_lim * sin(th) + 0;

for which_targ = 1
    cmap = zeros(length(target_coords), 3);
    cmap(which_targ,:) = cmap_targ(which_targ,:);
    figure;
    for targ_id = 1:size(target_coords,1)
        p = plot(target_coords(targ_id,1), target_coords(targ_id,2), 'o',...
            'MarkerEdgeColor', 'k', 'MarkerFaceColor',  'k', 'MarkerSize', 10,...
            'LineWidth',2.5);
        hold on
    end
    h = plot(xunit, yunit, 'linewidth', 3, 'color', 'k');
    hold on
    h = plot(xunit2, yunit2, 'linewidth', 3, 'color', 'k');
    axis square
    box off
    xlim([-1*grid_lim,grid_lim])
    ylim([-1*grid_lim,grid_lim])
    xline(0)
    yline(0)
    f.CData = [upper_roi_cmap; lower_roi_cmap;left_roi_cmap; right_roi_cmap];
    set(gcf,'color','w')
    set(gca,'Xticklabels',[])
    set(gca,'Yticklabels',[])
    axis off
    %saveas(gcf, fullfile(path2project, sprintf('derivatives/target_icon_%i.png', which_targ)));
end
set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 3, 3])
