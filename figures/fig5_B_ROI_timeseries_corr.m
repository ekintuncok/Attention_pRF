s0_attentionpRF;

try
    load(fullfile(path2project, 'derivatives/amplitude_data/att_resp_reorg_pseudotimeseries.mat'));
    fprintf('>> Data successfully loaded!\n');
catch ME
    analysis_type = 'MStimeseries';
    s3_get_amplitude_data;
end

crr_roi_avg = zeros(length(subject_list), length(ROIs));
crr_roi = zeros(length(subject_list),num_targets, length(ROIs));

timeseries = squeeze(mean(subj_averaged_attention_activity,1, 'omitnan'));

% Prepare the baseline-att comparisons at each subject to use later:
subj_timeseries_in_out_difference = squeeze(subj_averaged_attention_activity(:,:,:,1,:)-subj_averaged_attention_activity(:,:,:,3,:));
subj_timeseries_distributed = squeeze(subj_averaged_attention_activity(:,:,:,2,:));

subj_timeseries_in_out_difference = squeeze(mean(subj_timeseries_in_out_difference, 3));
subj_timeseries_distributed = squeeze(mean(subj_timeseries_distributed, 3));

n=1;
indices = 1:24;
indices_reor = reshape(indices, [4,6]);
% averaged correlations:
iter = 1;
figure;
for roi = 1:length(ROIs)
    subplot(3, 2, roi)
    data_to_plot = squeeze(mean(timeseries(roi,:,:,:),2));

    % normalize the ROI data:
    %data_to_plot = data_to_plot/sum(data_to_plot(:));
    attend_location = mean(reshape(data_to_plot(1,:),n,[]),1);
    attend_all = mean(reshape(data_to_plot(2,:),n,[]),1);
    attend_out = mean(reshape(data_to_plot(3,:),n,[]),1);

    % plot the error bars of difference (att RF - att OUT):
    diff = attend_location - attend_out;
    s = scatter(attend_all, diff,5,'MarkerEdgeColor','k','MarkerFaceColor','w','Marker','o','LineWidth',1);
    h = lsline;
    h.LineWidth = 2;
    h.Color = [112, 41, 99]/255;
    hold on
    scatter(attend_all(49), diff(49),5,'MarkerEdgeColor','k','MarkerFaceColor','k','Marker','o','LineWidth',1)

    crr = corrcoef(attend_all, diff);
    crr_roi_avg(roi) = crr(2);
    hold on
    % 
    % if iter == 1
    %     xlabel('Distributed')
    %     ylabel('Attend in - attend out')
    % end
    %title(ROIs{roi})
    ylim([-0.1, 0.6])
    xlim([-0.1, 0.6])
    set(gca, 'xticklabel', [], 'yticklabel', [])
     iter = iter+1;
    set(gca, 'fontname', 'Roboto','FontSize', 18);
    set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
end
set(gcf,'color','w')
set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 6, 8])


%fig_tag = fullfile(path2project,'figfiles/','fig_baseline_vs_att_gain.png');
%print(gcf,fig_tag,'-dpng','-r300');

% figure;
% for targ = 1:4
%     iter = 1;
%     for roi = 1:length(ROIs)
% 
%         subplot(length(ROIs),4,indices_reor(targ, roi))
%         data_to_plot = squeeze(timeseries(roi,targ,:,:));
% 
%         attend_location = mean(reshape(data_to_plot(1,:),n,[]),1);
%         attend_all = mean(reshape(data_to_plot(2,:),n,[]),1);
%         attend_out = mean(reshape(data_to_plot(3,:),n,[]),1);
% 
%         % plot the error bars of difference (att RF - att OUT):
%         diff = attend_location - attend_out;
%         s = scatter(attend_all, diff,'MarkerEdgeColor','k','MarkerFaceColor','w','Marker','o','LineWidth',2);
%         h = lsline;
%         h.LineWidth = 2;
%         h.Color = [0,0,0];
% 
%         crr = corrcoef(attend_all, diff);
%         crr_roi(sub, targ, roi) = crr(2);
%         hold on
%         if roi == 1
%             if targ == 1
%                 title('UVM')
%             elseif targ ==2
%                 title('LVM')
%             elseif targ ==3
%                 title('LHM')
%             elseif targ ==4
%                 title('RHM')
%             end
%         end
%         if iter == 1
%             xlabel('Distributed')
%             ylabel('Attend in - attend out')
%         end
%         %title(ROIs{roi})
%         ylim([-0.1, 0.6])
%         xlim([-0.1, 0.6])
%         iter = iter+1;
% 
%         set(gca, 'fontname', 'Roboto','FontSize', 18);
%         set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
%     end
%     set(gcf,'color','w')
%     set(gcf,'position',[0 0 200 1200])
% end


%fig_tag = fullfile(path2project,'figfiles/','fig_baseline_vs_att_gain.png');
%print(gcf,fig_tag,'-dpng','-r300');
% clims = [-0.3,0.3];
% figure;imagesc([squeeze(crr_roi(sub, :,:))',squeeze(crr_roi_avg(sub, :))'], clims)
% set(gca, 'XTick', 1:num_targets+1);
% set(gca, 'XTickLabel', {'UVM','LVM','LHM','RHM', 'Averaged'}, 'FontSize', 18); % set x-axis labels
% set(gca, 'YTick', 1:length(ROIs), 'FontSize', 18, 'FontName', 'Roboto'); % center y-axis ticks on bins
% set(gca, 'YTickLabel', ROIs); % set y-axis labels
% %title({'Correlation between (attIn-attOut) and distributed'}, 'FontSize', 14); % set title
% colormap(redblue)
% colorbar() % enable colorbar
% set(gcf, 'color','white')
% axis square
% set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 6, 8])
% 

%% bootstrap the averaged correlations for testing against the null hypothesis:
lw_ci = zeros(length(ROIs),1);
up_ci = zeros(length(ROIs),1);
isInside = zeros(length(ROIs),1);
correlation_vals = zeros(length(ROIs), 1000);
for n = 1:1000
    rand_subj_ids = datasample(1:length(subject_list),length(subject_list));
    subsampled_dat_att = subj_timeseries_in_out_difference(rand_subj_ids,:,:);
    subsampled_dat_neut = subj_timeseries_distributed(rand_subj_ids,:,:);
    for roi = 1:length(ROIs)
        roi_dat_att = squeeze(subsampled_dat_att(:, roi, :));
        roi_dat_neut = squeeze(subsampled_dat_neut(:, roi, :));
        sample_corr = ones(length(subject_list), 1);
        for sub = 1:size(subsampled_dat_neut, 1)
            pr_r = corrcoef(roi_dat_att(sub,:), roi_dat_neut(sub,:), 'Rows','complete');
            sample_corr(sub, 1) = pr_r(2);
        end
        correlation_vals(roi, n) = mean(sample_corr, 'omitnan');
    end
end

%ci = prctile(correlation_vals', [low_prct_range, high_prct_range]);

%
% for roi = 1:length(ROIs)
%     curr_corrs = crr_roi_avg(:, roi);
%     [lw_ci(roi,1), up_ci(roi,1)] = calculate_bootstrapped_confidence_interval(curr_corrs, 'mn');
%     isInside(roi,1) = discretize(0, [lw_ci(roi, 1),up_ci(roi,1)])==1;
% end
% 
% lw_ci = zeros(length(ROIs),num_targets);
% up_ci = zeros(length(ROIs),num_targets);
% isInside = zeros(length(ROIs),num_targets);
% 
% for roi = 1:length(ROIs)
%     for targ = 1:num_targets
%         curr_corrs = crr_roi(:, targ, roi);
%         [lw_ci(roi,targ), up_ci(roi,targ)] = calculate_bootstrapped_confidence_interval(curr_corrs, 'mn');
%         isInside(roi, targ) = discretize(0, [lw_ci(roi, targ),up_ci(roi,targ)])==1;
%     end
% end
