true_diff_subj = zeros(length(subject_list), length(ROIs));
for roi = 1:length(ROIs)
    for subj = 1:length(subject_list)
        idx = distance_in_att_distributed(:,1) == subj & distance_in_attend_target(:,2) == roi;
        true_diff_subj(subj, roi) = nanmean(distance_in_att_distributed(idx,3) - distance_in_attend_target(idx,3));
    end
    true_sample_diff(roi) = nanmean(true_diff_subj(:, roi), 1);
end


roi_colors = [217, 91, 72
    17, 17, 80
    29, 143, 177
    242, 141, 157
    0,109,44
    225,0, 51]/255;

num_reps = 10000;
edges = linspace(-0.6,0.6,75);
figure;
for roi = 1:length(ROIs)
    resample_difference = zeros(1,num_reps);
    for iter = 1:num_reps
        difference = true_diff_subj(:, roi);
        difference = difference(~isnan(difference));
        signs = randsample([-1,1], length(difference), 'true');
        resamp = difference .* signs';
        resample_difference(iter) = mean(resamp);
    end

    true_diff = abs(true_sample_diff(roi));
    high_prob = length(resample_difference(resample_difference > true_diff))/num_reps;
    low_prob = length(resample_difference(resample_difference < -1*true_diff))/num_reps;
    prob(roi) = high_prob + low_prob;

    histogram(resample_difference,edges,"FaceColor",roi_colors(roi,:), 'EdgeColor', roi_colors(roi,:),'FaceAlpha',0.5,'EdgeAlpha',1)
    hold on
    xline(-1* true_sample_diff(roi),'color', roi_colors(roi,:),'LineWidth',3) % multiplied by -1 because of the reversed way of calculating
    % the difference at the beginning 
end

axis square
ylabel('Iteration counts')
xlabel({'Mean distance difference to', 'attentional target (deg)'})
set(gcf,'color','w')
legend('V1','','V2','','V3','','hV4','','V3AB','','LO1','','IPS0','')
legend boxoff
set(gca,'FontName','roboto',    'fontsize',25)
set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)
%fig_tag = fullfile(path2project,'figfiles/','fig_perm_test_avg_shifts.png');
%print(gcf,fig_tag,'-dpng','-r300');

figure;
pp = plot(prob,'s', 'MarkerSize',10, 'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'xtick',1:length(ROIs),'xticklabel',ROIs)
ylim([-0.1,0.7])
%ylabel('probability of rnd obtaining the effect')
axis square
hold on
yline(0.05,'color','k')
set(gca,'FontName','Roboto',    'fontsize',20)
set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)
set(gcf,'position',[0 0 220 200])
set(gcf,'color','w')
ax = gca;
yl = ylim(ax); 
axis(ax, 'tight')
ylim(ax, yl)
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.1)
%fig_tag = fullfile(path2project,'figfiles/','fig_perm_test_avg_shifts_prctg.png');
%print(gcf,fig_tag,'-dpng','-r300');
