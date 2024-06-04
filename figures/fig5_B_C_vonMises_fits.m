s0_attentionpRF;
try
    load(fullfile(path2project, 'derivatives/amplitude_data/vonmises_output.mat'));
    fprintf('>> Data successfully loaded!\n');
catch ME
    s6_attpRF_attMod_afo_pangle_diff;
end
pa_distance_bins = -180:20:180;

Y              = squeeze(mean(output.att_resp_all_bars,1,'omitnan'));
avg_recon_data = squeeze(mean(output.recon_data, 'omitnan'));
avg_est_params = squeeze(mean(output.est_params,1, 'omitnan'));
fwhm = mean(output.fwhm, 'omitnan');
fig_code = 1;
CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;
lower_ci_bin_data = zeros(length(ROIs), size(output.est_params,3), 1);
upper_ci_bin_data = zeros(length(ROIs), size(output.est_params,3), 1);
d_o_vonMises =  @(a1, a2, kappa1, kappa2, baseline, mu, x) a1*(exp((kappa1*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa1))) - a2*(exp((kappa2*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa2))) + baseline;


for roi = 1:length(ROIs)
    for b = 1:size(output.att_resp_all_bars, 3)
        confidence_int = prctile(output.att_resp_all_bars(:,roi, b), [low_prct_range, high_prct_range]);
        lower_ci_bin_data(roi, b, :) = confidence_int(1);
        upper_ci_bin_data(roi, b, :) = confidence_int(2);
    end
end

recon_cis = cat(3, lower_ci_bin_data', upper_ci_bin_data');
figure;
for roi = 1:length(ROIs)
    subplot(2,3, roi)
    pp = plot(pa_distance_bins, Y(roi,:), 'o','markerSize',6,'linestyle', 'none');
    pp.MarkerFaceColor = [0,0,0];
    pp.MarkerEdgeColor = [0,0,0];
    hold on
    ss = plot(pa_distance_bins,avg_recon_data(roi,:), 'linewidth',2);
    ss.Color = [0,0,0];
    hold on
    errbar = Y(roi,:)' - squeeze(recon_cis(:,roi,:));
    s = shadedErrorBar(pa_distance_bins, Y(roi,:), abs(errbar),'lineProps',{'color',[0,0,0]}, 'patchSaturation', 0.3);
    ylim([-0.17, 0.15])
    xlim([-190,190])
    axis square
    %title(fit_title)
    yline(0,'k', 'LineWidth', 0.5)
    box off
    set(gcf,'color','w')
    set(gca,'FontName','roboto',    'fontsize',25)
    set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
end

set(gcf, 'position', [0,0,600,600])

center_param = rad2deg(output.est_params(:,:,5));

for ii = 1:size(center_param, 1)
    for jj = 1:size(center_param, 2)
        if center_param(ii, jj) > 180
            center_param(ii, jj) = center_param(ii, jj) - 360;
        end
    end
end

reparameterized_estimates = cat(3, max(output.recon_data, [],3), min(output.recon_data, [],3), center_param, output.angle_intercept);

lower_ci = zeros(length(ROIs), size(output.est_params,3)+1, 1);
upper_ci = zeros(length(ROIs), size(output.est_params,3)+1, 1);
num_iterations = 1000;

for roi = 1:length(ROIs)
    for p = 1:size(reparameterized_estimates, 3)+1
        if p < 5
            confidence_int = prctile(reparameterized_estimates(:,roi, p), [low_prct_range, high_prct_range]);
        elseif p == 5
            confidence_int = prctile(reparameterized_estimates(:,roi, 1)-reparameterized_estimates(:,roi, 2), [low_prct_range, high_prct_range]);
        end
        lower_ci(roi, p, :) = confidence_int(1);
        upper_ci(roi, p, :) = confidence_int(2);
    end
end


avg_params = squeeze(mean(reparameterized_estimates,1, 'omitnan'));
titles = {'Peak', 'Trough', 'Center', 'Spread'};
ylabels = {'% BOLD change', '% BOLD change', 'distance from target (°)','degrees (°)'};
lims = [-0.15, 50, 0.19, 200];
yticks_list = [-0.05, 0, 0.1, 0.2, 0.3, 0.4;...
    -0.3, -0.2, -0.1, 0, 0.1, 0.2;...
    -40 -30 -20, -10, 0, 10;...
    0, 100, 150, 200, 250, 300];
figure;
pos=[1,1,2];
iter=1;
for est_p = [1, 2, 4]
    subplot(1,2,pos(iter))

    if est_p == 1
        err_clr = [204, 95, 90]/255;
    elseif est_p == 2
        err_clr = [42, 76, 101]/255;
    elseif est_p == 4
        err_clr = [0,0,0];
    end
    b = plot(avg_params(:,est_p)','o','MarkerSize',1,'MarkerEdgeColor',err_clr, 'MarkerFaceColor',err_clr,...
        'linewidth',1.5);
    hold on
    [ngroups,nbars] = size(avg_params(:,est_p)');
    if est_p == 2
        s = plot([avg_params(:,est_p-1)+abs(avg_params(:,est_p))]','o','MarkerSize',1,'MarkerEdgeColor',[0,0,0],...
            'MarkerFaceColor',[0,0,0],...
            'linewidth',1.5);
        x = s.XData;
        e = errorbar(x, [avg_params(:,est_p-1)+abs(avg_params(:,est_p))]', [avg_params(:,est_p-1)+abs(avg_params(:,est_p))]' - lower_ci(:,5)',...
            [avg_params(:,est_p-1)+abs(avg_params(:,est_p))]' - upper_ci(:,5)','color',[0,0,0],'linewidth',2,'linestyle', 'none');
        e.CapSize = 5;
    end

    % Get the x coordinate for the error bars:
    x = b.XData;
    e = errorbar(x, avg_params(:,est_p)', avg_params(:,est_p)' - lower_ci(:,est_p)',...
        avg_params(:,est_p)' - upper_ci(:,est_p)','color',err_clr,'linewidth',2,'linestyle', 'none');
    e.CapSize = 5;
    hold on
    yline(0)
    %ylabel(ylabels{est_p})
    set(gcf,'color','w')
    axis square
    ax = gca;
    yl = ylim(ax);
    yticks(yticks_list(est_p, :));
    %title(titles{est_p});
    axis(ax, 'tight')
    ylim(ax, yl)
    xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.2)
    if est_p == 1
        ylim([lims(1), lims(3)])
    elseif est_p == 4
        ylim([lims(2), lims(4)])

    end
    set(gca,'FontName','roboto',    'fontsize',18)
    set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
    set(gca,'Xtick',[1:6],'XTickLabel',ROIs)
    iter=iter+1;
end
set(gcf, 'position', [0,0,600,600])
set(gcf,'color','w')


% Run ANOVAS on reparameterized params:
isinside = zeros(length(ROIs), length(ROIs), size(reparameterized_estimates, 3));

for roi = 1:length(ROIs)
    for params = 1:size(reparameterized_estimates,3)
        for comp_roi = 1:length(ROIs)
            l_inside = discretize(lower_ci(comp_roi, params), [lower_ci(roi, params),upper_ci(roi,params)])==1;
            u_inside = discretize(upper_ci(comp_roi, params), [lower_ci(roi, params),upper_ci(roi,params)])==1;
            if l_inside == 1 || u_inside == 1
                isinside(roi, comp_roi, params) = 1;
            else
                isinside(roi, comp_roi, params) = 0;
            end
        end
    end
end

% for ii = 1:4
%     overlap_dist = tril(isinside(:,:,ii))' + triu(isinside(:,:,ii));
%     figure(ii)
%     imagesc(overlap_dist)
%     colorbar()
% end


