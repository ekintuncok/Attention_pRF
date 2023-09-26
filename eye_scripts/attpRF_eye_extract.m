% extract average gaze position for each scan session for separate precue
% conditions:
s0_attentionpRF;
filename2 = '/usr/local/bin/edf2asc';
edf_run_tags = {'01','02','03','04','05','06','07','08','09','10'};
eye_data_dir = '/Volumes/server/Projects/attentionpRF/EDFfiles';
path2designmat = '/Volumes/server/Projects/attentionpRF/BehaviorData/BehavioralRaw';
data = [];
for subj_idx = 1:length(subject_list)
    subject = subject_list(subj_idx).name;
    disp(subject)
    session_list = dir(fullfile(path2designmat, subject, '*experimentalDesignMat*'));
    subject_gaze_data = [];
    subject_pupil_data = [];
    for session_idx = 1:length(session_list)
        session = sprintf('ses-nyu3t0%i', session_idx);
        session_gaze_data = [];
        session_pupil_data = [];
        gaze_position = zeros(52, 7);
        for run_idx = 1:length(edf_run_tags)
            if exist(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})), 'file')
                load(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_Dat_all.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})));
                load(fullfile(eye_data_dir, subject, session, 'MATs', sprintf('%s_H%s_blink.mat',extractAfter(subject,"subj"), edf_run_tags{run_idx})));
                for trial_number = 1:52
                    % extract the gaze data:
                    curr_timepoints = data_run(:,4) == trial_number;
                    trial_eye_pos = data_run(curr_timepoints, 7:8);
                    average_gaze_post = mean(trial_eye_pos);
                    gaze_position(trial_number, 1) = subj_idx;
                    gaze_position(trial_number, 2) = session_idx;
                    gaze_position(trial_number, 3) = run_idx;
                    gaze_position(trial_number, 4) = trial_number;
                    time_stamp = data_run(curr_timepoints, 6);
                    stamp_for_trial_cond = find(data_run(:,6) == time_stamp(1));
                    gaze_position(trial_number, 5) = data_run(stamp_for_trial_cond, 5);
                    gaze_position(trial_number, 6:7) = average_gaze_post;
                end
            else
                fprintf('Warning: no data for the current run %i\n', run_idx)
                gaze_position = NaN(52, 7);
            end
            session_gaze_data = cat(1, session_gaze_data, gaze_position);
            %             session_pupil_data = cat(1, session_pupil_data, pupil_size);
        end
        subject_gaze_data = cat(1, subject_gaze_data, session_gaze_data);
        %subject_pupil_data = cat(1, subject_pupil_data, session_pupil_data);
    end
    data = cat(1, data, subject_gaze_data);
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
fig_tag = fullfile(path2project,'figfiles/','fig_eye_pos_by_cond.png');
print(gcf,fig_tag,'-dpng','-r300');


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
fig_tag = fullfile(path2project,'figfiles/','fig_mean_eye_pos_by_cond.png');
print(gcf,fig_tag,'-dpng','-r300');
