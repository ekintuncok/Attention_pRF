% make sure the pRF shift data is extracted and saved in a folder in the
% project path!
s0_attentionpRF;

try
    load(fullfile(path2project, 'derivatives/prf_shift_data/distance_in_focal.mat'));
    load(fullfile(path2project, 'derivatives/prf_shift_data/distance_in_distributed.mat'));
    shf_f = load(fullfile(path2project, 'derivatives/prf_shift_data/distance_in_focal_shuffled.mat'));
catch ME
    s7_extract_pRFshifts;
end
distance_in_attend_target_shuffled = shf_f.distance_in_attend_target;

subj_mean = zeros(length(subject_list), length(ROIs));
subj_mean_shuffled = zeros(length(subject_list), length(ROIs));
low_ci = zeros(1,length(ROIs));up_ci = zeros(1,length(ROIs));
low_ci_shuffled = zeros(1,length(ROIs));up_ci_shuffled = zeros(1,length(ROIs));

% get the confidence intervals:
for roi = 1:length(ROIs)
    for subj = 1:length(subject_list)
        indices = distance_in_attend_target(:,1) == subj & distance_in_attend_target(:,2) == roi;
        difference_in_distance = [];
        difference_in_distance_shuffled = [];

        if sum(indices) > 0
            for trg = 1:size(distance_in_attend_target,2)-2
                curr_focal_data = distance_in_attend_target(indices,trg+2);
                curr_focal_data_shuffled = distance_in_attend_target_shuffled(indices,trg+2);
                curr_distributed_data = distance_in_att_distributed(indices,trg+2);
                difference_in_distance(:, trg) = curr_focal_data - curr_distributed_data;
                difference_in_distance_shuffled(:, trg) = curr_focal_data_shuffled - curr_distributed_data;
            end
            subj_mean(subj,roi) = mean(difference_in_distance, 'all');
            subj_mean_shuffled(subj,roi) = mean(difference_in_distance_shuffled, 'all');
        else
            subj_mean(subj, roi) = NaN;
            subj_mean_shuffled(subj, roi) = NaN;
        end
    end
    [low_ci(roi), up_ci(roi)] = calculate_bootstrapped_confidence_interval(subj_mean(:,roi), 'mn');
    [low_ci_shuffled(roi), up_ci_shuffled(roi)] = calculate_bootstrapped_confidence_interval(subj_mean_shuffled(:,roi), 'mn');
end


% average across ROI
avg_shift_data_att_target = zeros(length(ROIs), 1);avg_shift_data_att_other = zeros(length(ROIs), 1);

for roi = 1:length(ROIs)
    indices = distance_in_attend_target(:,2) == roi;
    avg_shift_data_att_target(roi,:) = mean(distance_in_attend_target(indices,3:end), 'all');
    avg_shift_data_att_other(roi,:) = mean(distance_in_att_distributed(indices,3:end), 'all');
end

data_tp = mean(subj_mean,1, 'omitnan');
data_tp_shf = mean(subj_mean_shuffled,1, 'omitnan');

figure;
for roi = 1:length(ROIs)
    line([2*roi-1, 2*roi],[data_tp(1,roi),data_tp(1,roi)], 'color','k','linewidth',5);
    %hold on
    %line([2*roi-1, 2*roi],[data_tp_shf(1,roi),data_tp_shf(1,roi)], 'color','k','linewidth',5);
end
xticklabels(ROIs)
hold on
s= plot((1.5:2:11.5), subj_mean, 'o','MarkerSize',4, 'MarkerEdgeColor',[0,0,0], 'MarkerFaceColor', [0,0,0],...
    'linewidth',2);
box off
hold on
errBar2 = errorbar((1.5:2:11.5)+0.65, data_tp_shf', data_tp_shf'-low_ci_shuffled', data_tp_shf'-up_ci_shuffled',...
    'color','r','linestyle','none','linewidth',2);
hold on 
errBar1 = errorbar((1.5:2:11.5), data_tp', data_tp'-low_ci', data_tp'-up_ci',...
    'color',[65,171,93]/255,'linestyle','none','linewidth',3);
errBar2.CapSize = 0;
ax = gca;
yl = ylim(ax);
axis(ax, 'tight')
ylim(ax, yl)
xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.1)
axis square
set(gca,'FontName','Roboto', 'fontsize',20)
set(gca,'TickLength', [0.015 0.015], 'LineWidth', 2)
set(gcf,'color','w')
cond_check = 0;
if cond_check == 1
    ylabel({'Distance to a distractor (deg)'})
    ylim([-0.2, 1])
    yticks(fliplr([-0.8 -0.6 -0.4 -0.2 0 0.2]*-1))
else
    ylabel({'Distance to attentional target (deg)'})
    ylim([-1, 0.2])
    yticks([-1:0.2:0.2])
end
set(gca,'Xtick',  (1.5:2:11.5), 'xticklabel',[])
set(gcf, 'Position', [0 0 500 500])
hold on
yline(0, '--', 'linewidth',1.5)

%fig_tag = fullfile(path2project,'figfiles/','fig_avg_prf_shifts_diff.png');
%print(gcf,fig_tag,'-dpng','-r300');

attpRF_shifts_perm_tests;
