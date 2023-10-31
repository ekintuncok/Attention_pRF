left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;
cmap_targ = [upper_roi_cmap;lower_roi_cmap;left_roi_cmap;right_roi_cmap];
figure;
b = bar(measured_responses,'FaceColor',[1,1,1], 'EdgeColor',lower_roi_cmap);
b.LineWidth = 3;
b.BarWidth = 1;
hold on
plot(predicted_responses,'color','k','linewidth',3)
axis square
legend('Predicted pRF responses', 'Measured responses')
%legend boxoff
%ylabel('Normalized % BOLD change')
ylim([-0.15,0.45])
xlim([0,48])
set(gca,'xticklabels',[])
set(gcf, 'color','w')
set(gcf,'position',[0,0,400,800])
set(gca,'FontName','roboto',    'fontsize',25)
set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)

fig_tag = fullfile(path2project,'figfiles/','fig_predicted_pRF_response.png');
print(gcf,fig_tag,'-dpng','-r300');

% visualize the picked RF
prf_params(1,1) =  x_fits(best_vert);
prf_params(1,2) =  y_fits(best_vert);
prf_params(1,3) = sigma_minor(best_vert);
col = lower_roi_cmap;
plotgrid = 1;
makeVFPRF(prf_params,col,plotgrid)
fig_tag = fullfile(path2project,'figfiles/','fig_example_pRF.png');
print(gcf,fig_tag,'-dpng','-r300');