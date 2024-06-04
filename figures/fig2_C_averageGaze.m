if ~ exist('config.mat','file')
    s0_attentionpRF;
else
    load('config.mat');
end

try
    load(fullfile(path2project, sprintf('EDFfiles/EyeAnalyzed/EyeData.mat')));
catch ME
    warning('>> I cannot find processed eye tracking data. Run /eye_scripts/attpRF_eye_extract.m, then /eye_scripts/attpRF_eye_convert.m')
end

x_pixels = 1920;
y_pixels = 1080;
center_X = x_pixels/2;
center_Y = y_pixels/2;
% ppd:
ScreenHeight     = 36.2;
ViewDistance     = 85;
visual_angle = (2*atand(ScreenHeight/(2*ViewDistance)));
ppd = round(y_pixels/visual_angle);

data(:,8) = (data(:,6) - center_X)/ppd;
data(:,9) = (data(:,7) - center_Y)/ppd;

left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;
cmap_targ = [upper_roi_cmap;lower_roi_cmap;left_roi_cmap;right_roi_cmap; [0,0,0]];
group_data = zeros(5, 2, length(subject_list));
figure;
for subj = 1:length(subject_list)
        subj_idx = data(:,1) == subj;
        mean_position_x = nanmean(data(subj_idx, 8));
        mean_position_y = nanmean(data(subj_idx, 9));
    for cond_idx = 1:5
        mask = data(:,1) == subj & data(:,5) == cond_idx;
        mean_gaze_deviation_per_cond(cond_idx,:) = [mean_position_x mean_position_y] - [mean(data(mask, 8)), mean(data(mask, 9))];
        plot(mean_gaze_deviation_per_cond(cond_idx,1), mean_gaze_deviation_per_cond(cond_idx,2), 'o',...
            'MarkerSize',3,'MarkerFaceColor', cmap_targ(cond_idx,:), 'MarkerEdgeColor', cmap_targ(cond_idx,:))
        hold on
    end
    group_data(:,:, subj) = mean_gaze_deviation_per_cond;
end
for ii = 1:5
    pp = plot(mean(squeeze(group_data(ii,1,:))), mean(squeeze(group_data(ii,2,:))), '^',...
        'MarkerSize', 10, 'MarkerFaceColor', cmap_targ(ii,:), 'MarkerEdgeColor', cmap_targ(ii,:));
end
xlim([-0.2,0.2])
ylim([-0.2,0.2])
xline(0)
yline(0)
if subj == 8
    %legend('Up', 'Down', 'Left', 'Right','Distributed','','')
end
%xlabel('Horizontal position (deg)')
%ylabel('Vertical Position (deg)')
set(gcf,'color','w')
set(gca,'fontsize',18)
set(gcf,'units','centimeter','position',[0,0,6,6])
set(gca,'TickLength', [0.02 0.02], 'LineWidth', 2)



%% mean eye position data across subjects: 
left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;
cmap_targ = [upper_roi_cmap;lower_roi_cmap;left_roi_cmap;right_roi_cmap; [0,0,0]];
target_coords = [0, 6; 0, -6; -6, 0; 6,0];

figure;
mean_position_x = nanmean(data(:, 8));
mean_position_y = nanmean(data(:, 9));
for cond_idx = 1:5
    mask = data(:,5) == cond_idx;
    mean_gaze_deviation_per_cond(cond_idx,:) = [mean_position_x mean_position_y] - [mean(data(mask, 8)), mean(data(mask, 9))];
    plot(mean_gaze_deviation_per_cond(cond_idx,1), mean_gaze_deviation_per_cond(cond_idx,2), 'o',...
        'MarkerSize',10,'MarkerFaceColor', cmap_targ(cond_idx,:), 'MarkerEdgeColor', cmap_targ(cond_idx,:))
    hold on
end
for targ_id = 1:size(target_coords,1)
    p = plot(target_coords(targ_id,1), target_coords(targ_id,2), 'o',...
        'MarkerEdgeColor', cmap_targ(targ_id,:), 'MarkerFaceColor',  cmap_targ(targ_id,:), 'MarkerSize', 15,...
        'LineWidth',2.5);
    hold on
end

xlim([-7,7])
ylim([-7,7])
xline(0)
yline(0)
if subj == 8
    %legend('Up', 'Down', 'Left', 'Right','Distributed','','')
end
xlabel('Horizontal position (deg)')
ylabel('Vertical Position (deg)')
set(gcf,'color','w')
set(gca,'fontsize',18)
set(gcf,'units','centimeter','position',[0,0,8,8])
set(gca,'TickLength', [0.02 0.02], 'LineWidth', 2)

