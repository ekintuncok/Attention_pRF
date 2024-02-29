% check the bar duration effects:
s0_attentionpRF;
data_type = 'raw';
trial_types = {'all'};
onset_type = {'_2_trial','_2_gabor'};

colorMapSc = [0,0,0;...
    0,0,0]/255;
iter = 1;

figure;
for event_id = 1:length(onset_type)
    try
        load(fullfile(path2project, sprintf('derivatives/trial_triggered_averages/all_trial_triggered_averages%s_%s.mat', onset_type{event_id}, data_type)));
    catch ME
        warning('>> I cannot find the event-locked timeseries data. Try running /main_scripts_for_figures/s5_run_trial_trig_avg.m')
    end
    
    tta_TRs = 8;
    TTA_subj = squeeze(mean(TTA, 4, 'omitnan'));
    num_iterations = 1000;
    CI_range = 68;
    low_prct_range = (100-CI_range)/2;
    high_prct_range = 100-low_prct_range;
    ci_diff = zeros(2, length(ROIs), length(trial_types), tta_TRs+1);
    comp_id_1 = 1;
    comp_id_2 = 3;
    % get the error bars:
    for roi_idx = 1:length(ROIs)
        for trial_ty = 1:length(trial_types)+1
            data_to_boot = squeeze(TTA_subj(trial_ty, :, roi_idx, :, :));
            for tr_id = 1:size(data_to_boot, 3)
                att_effect_tr = (data_to_boot(:,comp_id_1,tr_id)-data_to_boot(:,comp_id_2,tr_id));
                btstrp_gain_data = bootstrp(num_iterations, @mean, att_effect_tr);
                ci_diff(:, roi_idx, trial_ty, tr_id)= prctile(btstrp_gain_data, [low_prct_range, high_prct_range]);
            end
        end
    end

    gab_ons = [1.6,2.6];
    for trial_ty = 1
        for roi_idx = 1:length(ROIs)

            data_to_plot_1s = squeeze(mean(squeeze(mean(TTA(trial_ty, :, roi_idx, :, :, :), 4, 'omitnan')), 1, 'omitnan'));
            data_to_plot_2s = squeeze(mean(squeeze(mean(TTA(trial_ty+1, :, roi_idx, :, :, :), 4, 'omitnan')), 1,'omitnan'));
            subplot(2,length(ROIs),iter)
            att_rf_1s = (data_to_plot_1s(comp_id_1,:) - data_to_plot_1s(comp_id_2,:));
            att_rf_2s = (data_to_plot_2s(comp_id_1,:) - data_to_plot_2s(comp_id_2,:));

       
            plot(0:length(att_rf_1s)-1,att_rf_1s,'color',colorMapSc(event_id,:),'LineWidth', 2)
            hold on
            plot(0:length(att_rf_2s)-1,att_rf_2s,'--','color',colorMapSc(event_id,:),'LineWidth', 2)

            errbar1 = att_rf_1s-squeeze(ci_diff(:,roi_idx,trial_ty,:));

            errbar2 = att_rf_2s-squeeze(ci_diff(:,roi_idx,trial_ty+1,:));

            shadedErrorBar(0:length(att_rf_1s)-1, att_rf_1s, abs(errbar1),'lineProps',{'color',colorMapSc(event_id,:)}, 'patchSaturation', 0.5);
            hold on
            shadedErrorBar(0:length(att_rf_2s)-1, att_rf_2s, abs(errbar2),'lineProps',{'color',colorMapSc(event_id,:)}, 'patchSaturation', 0.2);

            ylim([-0.15, 0.35])
            xlim([0,  size(att_rf_1s,2)-1])
            set(gca, 'fontname', 'Roboto','FontSize', 23);
            hold on
            %if trial_ty == 2
            yline(0)
            set(gca,'TickLength', [0.02 0.02], 'LineWidth', 2)
            axis square
            %end
            xticks([0, 3, 6, 9])

            title(ROIs{roi_idx})
            if roi_idx == 1 &&  event_id == 1
                %legend('1 sec', '2 sec','','','')
                xlabel('Time (s) from the event onset')
                ylabel({'% BOLD change', '(Attend in - Attend out)'})
                %legend boxoff
            elseif roi_idx ~= 1 && event_id == 2
                set(gca,'Xticklabel',[]);
                set(gca,'Yticklabel',[]);
            end
            iter = iter + 1;
            hold on
            box off
        end
    end
    hold on
end
set(gcf,'color','w')
set(gcf,'Position', [0,0,1200,500])
fig_tag = fullfile(path2project,'figfiles/','fig_TTA_all_trials.png');
print(gcf,fig_tag,'-dpng','-r300');
