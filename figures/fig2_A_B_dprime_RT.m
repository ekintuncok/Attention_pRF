path2project = '/Volumes/server/Projects/attentionpRF';

try
    load(fullfile(path2project, sprintf('BehaviorData/BehaviorAnalyzed/behavioral_sensitivity.mat')));
    load(fullfile(path2project, sprintf('BehaviorData/BehaviorAnalyzed/reaction_time.mat')));
catch ME
    warning('>> I cannot find the event-locked timeseries data. Run /behavior/attpRF_behavior_analyze_group.m')
end

numconds = 5;
numcuetype = 3;

% Figure 1: Plot behavioral sensitivity
CIlower = zeros(numconds, numcuetype);
CIupper = zeros(numconds, numcuetype);
number_of_iterations = 1000;
for cond_idx = 1:numconds
    for cue_idx = 1:numcuetype
        data = dpri_data(cond_idx, cue_idx, :);
        [CIlower(cond_idx, cue_idx), CIupper(cond_idx, cue_idx)] = bootstrap_data2(number_of_iterations, data);
    end
end

dpri_data_group_avg = mean(dpri_data, 3);
titlesxAxis = {'Valid', 'Neutral', 'Invalid', '','',''};

CIhigh = CIupper-dpri_data_group_avg;
CIlow = CIlower-dpri_data_group_avg;
cue_colors = [204, 95, 90
    189,189,189
    42, 76, 101]/255;
figure;
subplot(1,2,1)
pp = plot(dpri_data_group_avg(1:4,:),'d', 'MarkerSize', 10, 'LineWidth',3);
pp(1).MarkerFaceColor = [204, 95, 90]/255;
pp(2).MarkerFaceColor = [189,189,189]/255;
pp(3).MarkerFaceColor = [42, 76, 101]/255;
pp(1).MarkerEdgeColor = [204, 95, 90]/255;
pp(2).MarkerEdgeColor = [189,189,189]/255;
pp(3).MarkerEdgeColor = [42, 76, 101]/255;
ylim([0.1,max(rt_data(:))+0.1])
ylabel('Reaction Time (s)')
set(gca,'xtick',[])
ax = gca;
yl = ylim(ax);
axis(ax, 'tight')
ylim(ax, yl)
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.3)
ylim([-0.5,5.4])
% % Find the Left Most Edge of each X Values bars
ylabel({'Sensitivity (d'')'})
set(gca,'xcolor','k')
axis square
hold on

for ss = 1:size(dpri_data,2)
    s = plot(squeeze(dpri_data(:,ss,:)), '.', 'markerfacecolor',cue_colors(ss,:),...
        'markeredgecolor',cue_colors(ss,:), 'markersize',14, 'LineWidth',1.5);
end
set(gca,'FontName','roboto',    'fontsize',25)
set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)
box off
errBar = errorbar(1:5, (dpri_data_group_avg),(CIlow),(CIhigh),'k','linestyle','none','linewidth',2);
errBar(1).CapSize = 0;errBar(2).CapSize = 0;errBar(3).CapSize = 0;
hold on


% Reaction time:
titlesBar   = {'UVM', 'LVM', 'LHM', 'RHM', 'Average'};
CIlower = zeros(numconds, numcuetype);
CIupper = zeros(numconds, numcuetype);
number_of_iterations = 1000;
for cond_idx = 1:numconds
    for cue_idx = 1:numcuetype
        data = rt_data(cond_idx, cue_idx, :);
        [CIlower(cond_idx, cue_idx), CIupper(cond_idx, cue_idx)] = bootstrap_data2(number_of_iterations, data);
    end
end

rt_group_avg = mean(rt_data, 3);
numLocations = 4;
colorRT =  [240,240,240
    189,189,189
    99,99,99]/255;

CIhigh = CIupper-rt_group_avg;
CIlow = CIlower-rt_group_avg;
subplot(1,2,2)
pp = plot(rt_group_avg(1:4,:),'s', 'MarkerSize', 10, 'LineWidth',3);
pp(1).MarkerFaceColor = [204, 95, 90]/255;%[1,1,1];
pp(2).MarkerFaceColor =  [189,189,189]/255;%[1,1,1];
pp(3).MarkerFaceColor =  [42, 76, 101]/255;%[1,1,1];
pp(1).MarkerEdgeColor = [204, 95, 90]/255;
pp(2).MarkerEdgeColor = [189,189,189]/255;
pp(3).MarkerEdgeColor = [42, 76, 101]/255;
ylim([0.1,0.9])
ylabel('Reaction time (s)')
set(gca,'XTick',[])
yticks([0.2,0.5,0.8])
ax = gca;
yl = ylim(ax);
axis(ax, 'tight')
ylim(ax, yl)
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.3)
axis square
hold on
box off
for ss = 1:size(rt_group_avg,2)
    s = plot(squeeze(rt_data(:,ss,:)), '.', 'markerfacecolor',cue_colors(ss,:),...
        'markeredgecolor',cue_colors(ss,:), 'markersize',14,'LineWidth',1.5);
end
hold on
errBar = errorbar(1:5, (rt_group_avg),(CIlow),(CIhigh),'k','linestyle','none','linewidth',2);
errBar(1).CapSize = 0;errBar(2).CapSize = 0;errBar(3).CapSize = 0;
set(gca,'FontName','roboto',    'fontsize',25)
set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)
set(gcf,'position',[0,0,800,400])
set(gcf,'color','white')

