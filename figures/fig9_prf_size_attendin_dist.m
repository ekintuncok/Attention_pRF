s0_attentionpRF;
eccen_limits = [1, 9];
binWidth     = linspace(eccen_limits(1),eccen_limits(2),9);

try
    load(fullfile(path2project, 'derivatives/prf_size_data/binned_eccen_size_data.mat'));
catch ME
    s9_extract_binned_prfSize;
end

eccen_binned = data(:,:,:,:,1);
size_binned = data(:,:,:,:,2);
eccen_binned_base = data(:,:,:,:,3);
size_binned_base = data(:,:,:,:,4);

% average across targets:
focal_eccen = squeeze(mean(eccen_binned,3,'omitnan'));
focal_size = squeeze(mean(size_binned,3,'omitnan'));

dist_eccen = squeeze(mean(eccen_binned_base,3,'omitnan'));
dist_size = squeeze(mean(size_binned_base,3,'omitnan'));

% get rid of the last bin (NaNs)
focal_eccen(:,:,9) = [];focal_size(:,:,9) = [];
dist_eccen(:,:,9) = [];dist_size(:,:,9) = [];

% calculate the error across subjects:
ci = zeros(2,3, length(binWidth)-1, length(ROIs));
for roi = 1:length(ROIs)
    for bin_idx = 1:length(binWidth)-1
        subject_data_focal = squeeze(focal_size(:, roi, bin_idx));
        subject_data_dist = squeeze(dist_size(:, roi, bin_idx));
        subject_difference_foc_dist = subject_data_focal -subject_data_dist;
        data = [subject_data_focal, subject_data_dist, subject_difference_foc_dist];
        [ci(1, :, bin_idx, roi), ci(2, :, bin_idx, roi)] = calculate_bootstrapped_confidence_interval(data,'mn');
    end
end

eccen_focal = squeeze(mean(focal_eccen,1,'omitnan'));
size_focal = squeeze(mean(focal_size,1,'omitnan'));

eccen_dist = squeeze(mean(dist_eccen,1,'omitnan'));
size_dist = squeeze(mean(dist_size,1,'omitnan'));

error_bars_diff = zeros(2, size(eccen_dist, 2), length(ROIs));
diff = zeros(size(eccen_dist, 2), length(ROIs));

figure;
for ind = 1:length(ROIs)
    subplot(2, 3, ind)
    eccen_to_fit = squeeze(eccen_dist(ind,:))';
    size_to_fit = squeeze(size_dist(ind,:))';

    %[output] = svd_regression(eccen_to_fit, size_to_fit);

    scatter(eccen_to_fit, size_to_fit, 30,'k', 'o');
    title(ROIs{ind})

    error_bars = size_to_fit'-squeeze(ci(:,2,:,ind));
    hold on
    shadedErrorBar(eccen_to_fit, size_to_fit, abs(error_bars),'lineProps',{'color',[0,0,0]})
    hold on

    eccen_to_fit = squeeze(eccen_focal(ind,:))';
    size_to_fit = squeeze(size_focal(ind,:))';

    %[output] = svd_regression(eccen_to_fit, size_to_fit);
    scatter(eccen_to_fit,size_to_fit, 30,'k', 'filled');

    %title(ROIs{ind})
    error_bars = size_to_fit'-squeeze(ci(:,1,:,ind));
    hold on
    shadedErrorBar(eccen_to_fit, size_to_fit, abs(error_bars),'lineProps',{'color',[0,0,0]}, 'patchSaturation', 0.5);
    hold on

    % plot the difference of focal from distributed:
    diff(:, ind) =(size_focal(ind,:)-size_dist(ind,:));

    scatter(eccen_to_fit,  diff(:, ind)',30, 'MarkerFaceColor',[112, 41, 99]/255, 'MarkerEdgeColor',[112, 41, 99]/255);

    error_bars_diff(:, :, ind) =  diff(:, ind)'-squeeze(ci(:,3,:,ind));
    shadedErrorBar(eccen_to_fit,  diff(:, ind)', abs(error_bars_diff(:,:,ind)),'lineProps',{'color',  [112, 41, 99]/255}, 'patchSaturation', 0.5);
    %xlim([binWidth(1), binWidth(end-1)])
    xlim([eccen_to_fit(1), eccen_to_fit(end)])
    yline(0,'k','linewidth',2)
    hold on
    xline(6,'--k','linewidth',2)
    if ind == 1 || ind == 2 || ind == 3
        l_lim = -1;
        u_lim = 4;
        yticks([-1, 0, 1, 2, 3])
    else
        l_lim = -2;
        u_lim = 6;
        yticks([-1, 0, 1, 2, 3, 4, 5])
    end
    xticks([2, 4, 6, 8])
    ylim([l_lim, u_lim])
    if ind == 4
        xlabel('pRF eccentricity (deg)')
        ylabel('pRF size (deg)')
    end
    if ind ~= 1 && ind ~= 4
        set(gca, 'yticklabel',[])
        set(gca, 'xticklabel',[])
    end
    box off
    axis square
    set(gca,'FontName','roboto','fontsize',23)
    set(gca,'TickLength', [0.015 0.015], 'LineWidth', 1.5)
    set(gcf,'color','w')
end
%set(gcf, 'position', [0,0,700,550])
%fig_tag = fullfile(path2project,'figfiles/','fig_prf_size_vs_eccen_quadrant_dist.png');
%print(gcf,fig_tag,'-dpng','-r300');

% test whether the distributed - focal distribution cross by 0
is_inside =zeros(length(ROIs), size(ci, 3));

for roi = 1:length(ROIs)
    for bin = 1:size(ci, 3)
        is_inside(roi, bin) = discretize(0, [squeeze(ci(1,3,bin,roi)),squeeze(ci(2,3,bin,roi))])==1;
    end
end

% plot the 0-1 results
%figure; imagesc(is_inside)
%colormap(hot)

num_t_tests = length(ROIs) * size(size_dist,2);
corrected_alpha = 0.05/num_t_tests;
% run t-tests:
for roi = 1:length(ROIs)
    for bin = 1:size(size_dist,2)
        curr_dat = [focal_size(:, roi, bin),dist_size(:, roi, bin)];
        curr_dat = curr_dat(sum(isnan(curr_dat), 2) == 0,:);
        [h(roi, bin),p(roi, bin), ci(:,roi, bin), stats] = ttest(curr_dat(:,1), curr_dat(:,2), 'alpha', corrected_alpha);
    end
end


