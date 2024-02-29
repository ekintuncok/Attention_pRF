s0_attentionpRF;

% If "attpRF_fit_logistics_to_TTA" has been run, and the output is saved,
% just load the fitting results:
try
    load(fullfile(path2project, 'derivatives/trial_triggered_averages/latency_of_attenional_modulation.mat'));
catch ME
    attpRF_fit_logistics_to_TTA;
end

onset_type = {'_2_trial', '_2_gabor'};
num_comps = 4; % rising and falling for 1 sec and 2 sec bars

CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;
ci_all = zeros(2, length(onset_type),  length(ROIs), 2);
for event_id = 1:length(onset_type)
    for roi = 1:length(ROIs)
        for c = 1:(num_comps/2)
            ci_all(:, event_id, roi, c) = prctile(diff_latency(event_id, roi, :, c), [low_prct_range, high_prct_range]);
        end
    end
end

lw_ci = squeeze(ci_all(1,:,:,:));
up_ci = squeeze(ci_all(2,:,:,:));
x_vals = [0.5:2.5:13;1:2.5:13.5];
ylims = [-4, 4; -2, 2];
expected_diff = [-1, 1];
cmaps = [183,61,61;
    22,112,12]/255;
iter=1;
figure;
for comp = 1:2
    for event_type = 1:2
        subplot(2,2,iter)
        pp = plot(x_vals(event_type, :),squeeze(mean(diff_latency(event_type,:,:,comp), 3, 'omitnan')),'o');
        pp.MarkerFaceColor = cmaps(event_type,:);
        pp.MarkerEdgeColor = cmaps(event_type,:);
        hold on
        errBar = errorbar(x_vals(event_type,:)', squeeze(mean(diff_latency(event_type,:,:,comp), 3, 'omitnan')), squeeze(mean(diff_latency(event_type,:,:,comp), 3, 'omitnan'))-lw_ci(event_type,:,comp),...
            squeeze(mean(diff_latency(event_type,:,:,comp), 3, 'omitnan'))-up_ci(event_type,:,comp),'linewidth',2,'linestyle', 'none');
        errBar.Color = cmaps(event_type,:);
        hold on
        yline(0)
        hold on
        ylim([ylims(comp, 1), ylims(comp, 2)])
        axis square
        box off
        set(gca, 'xtick',  mean(x_vals),'xticklabels',ROIs)
        set(gcf, 'color','w')
        set(gca,'TickLength', [0.015 0.015], 'LineWidth', 3)
        ax = gca;
        yl = ylim(ax);
        axis(ax, 'tight')
        ylim(ax, yl)
        xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.1)
        set(gca,'FontName','roboto', 'fontsize',18)
        iter = iter +1;
    end
end

set(gcf, 'position', [0,0,600,600])

fig_tag = fullfile(path2project,'figfiles/','fig_TTA_latency_comparison.png');
print(gcf,fig_tag,'-dpng','-r300');


% compare error bar overlaps:
isinside = zeros(length(ROIs), 2,2);
for roi = 1:length(ROIs)
    for comp = 1:2
        for event_type = 1:2
            isinside(roi, event_type, comp) = discretize(0, [lw_ci(event_type,roi, comp),up_ci(event_type,roi,comp)])==1;
        end
    end
end



