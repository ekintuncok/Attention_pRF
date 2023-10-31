s0_attentionpRF;

try
    load(fullfile(path2project, 'derivatives/amplitude_data/att_resp_reorg_pseudotimeseries.mat'));
    fprintf('>> Data successfully loaded!\n');
catch ME
    analysis_type = 'MStimeseries';
    s3_get_amplitude_data;
end

num_data_pts = 49;
subj_timeseries_in_out_difference = squeeze(subj_averaged_attention_activity(:,:,:,1,:)-subj_averaged_attention_activity(:,:,:,3,:));

% compute the confidence intervals:
ci = zeros(2, length(ROIs), num_targets, num_data_pts);
for roi = 1:length(ROIs)
    for condition = 1:num_targets
        data = squeeze(subj_timeseries_in_out_difference(:,roi, condition,:));
        param = 'mn';
        [ci(1, roi, condition, :), ci(2, roi, condition, :)] = calculate_bootstrapped_confidence_interval(data, param);
    end
end
timeseries = squeeze(mean(subj_averaged_attention_activity,1, 'omitnan'));
iter = 1;
kernel_to_smooth = [0.1:0.1:0.4, 0.5, fliplr(0.1:0.1:0.4)];
percent_change_att_roi = zeros(length(ROIs), num_targets);
percent_change_att_out = zeros(length(ROIs), num_targets);

figure;
for roi = 1:length(ROIs)
    for location = 3

        subplot(3, 2, iter)
        data_to_plot = squeeze(timeseries(roi,location,:,:));
        attend_location = data_to_plot(1,:);
        attend_all = data_to_plot(2,:);
        attend_out = data_to_plot(3,:);
        percent_change_att_roi(roi, location) = 100*(nanmean(attend_location) - nanmean(attend_all))./nanmean(attend_all);
        percent_change_att_out(roi, location) = 100*(nanmean(attend_out) - nanmean(attend_all))./nanmean(attend_all);

        k1 = [attend_location(1), kernel_to_smooth, attend_location(end)];
        k2 = [attend_all(1), kernel_to_smooth, attend_all(end)];
        k3 = [attend_out(1),kernel_to_smooth, attend_out(end)];

        sm_attend_location = conv(attend_location, k1/sum(k1), 'same');
        sm_attend_all      = conv(attend_all, k2/sum(k2), 'same');
        sm_attend_out      = conv(attend_out, k3/sum(k3), 'same');

        plot(1:num_data_pts-1, sm_attend_location(1:num_data_pts-1),'color',[204, 95, 90]/255,'LineWidth', 1)
        hold on
        plot(num_data_pts, sm_attend_location(num_data_pts),'o','MarkerSize', 2,'MarkerEdgeColor',[204, 95, 90]/255,'MarkerFaceColor',[204, 95, 90]/255)
        hold on
        plot(1:num_data_pts-1,sm_attend_all(1:num_data_pts-1),'color',[127,127,127]/255,'LineWidth',1)
        hold on
        plot(num_data_pts, sm_attend_all(num_data_pts),'o','MarkerSize', 2,'MarkerEdgeColor',[127,127,127]/255,'MarkerFaceColor',[127,127,127]/255)
        hold on
        plot(1:num_data_pts-1,sm_attend_out(1:num_data_pts-1), 'color', [42, 76, 101]/255,'LineWidth', 1)
        hold on
        plot(num_data_pts, sm_attend_out(num_data_pts),'o','MarkerSize', 2,'MarkerEdgeColor',[42, 76, 101]/255,'MarkerFaceColor', [42, 76, 101]/255)
        hold on
        yline(0)
        hold on

        xlim([1,50])

        % plot the error bars of difference (att RF - att OUT):
        diff = sm_attend_location - sm_attend_out;
        errbar = abs(diff - squeeze(ci(:, roi, location,:)));
        offset_errbars = -0.5;
        hold on
        plot(diff+offset_errbars,'linewidth', 1)
        s = shadedErrorBar(1:length(diff), diff+offset_errbars, abs(errbar),'lineProps',{'color',[112, 41, 99]/255}, 'patchSaturation', 0.3);
        yline(offset_errbars, 'color', 'k')
        if roi == 1 && location == 1
            legend('Attend RF', '','Distributed','', 'Attend out','')
            legend boxoff
        end
        ylim([-.7, 0.6])
        % if iter == 1
        %     ylabel('% BOLD change')
        % end
        iter = iter+1;
        set(gca,'xtick',[])
        set(gca,'ytick',[-0.5, -0.25, 0, 0.5])
        set(gca,'yticklabel',[])
        ax = gca;
        yl = ylim(ax);
        axis(ax, 'tight')
        ylim(ax, yl)
        xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.05)
        set(gca, 'fontname', 'Arial','FontSize', 18);
        box off
        set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
    end
end
set(gcf,'color','w')
set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 6, 8])