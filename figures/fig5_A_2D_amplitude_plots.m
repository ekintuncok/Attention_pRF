s0_attentionpRF;
try
    load(fullfile(path2project, 'derivatives/amplitude_data/amplitude_change_full_map.mat'));
    fprintf('>> Data successfully loaded!\n');
catch ME
    s2_get_amp_whole_map;
end

% the default setting for this data is that the map responses are rotated
% to align at the upper vertical meridian. Go back to the above called
% script (s2) to change this setting to 0 and plot unrotated responses
rotation = 1;

% Define the circle that is centered at the Gabor target locations for
% reference:
th = 0:pi/50:2*pi;
[xq,yq] = meshgrid(-12:.1:12, -12:.1:12);
yq = -1*yq;
xunit = length(xq)/4 * cos(th) + length(xq)/2;
yunit = length(yq)/4 * sin(th) + length(yq)/2;

%visualize the averaged focal vs distributed spread:
clims = [-0.15,0.15];
figure;
for roi = 1:length(ROIs)
    subplot(2, 3,roi)
    imagesc(mean(squeeze(mean(vf_map_to_plot(:,roi,:,:,:),1)),3),clims);
    title(ROIs{roi})
    axis square
    box off
    axis off
    hold on
    plot(xunit, yunit, 'linewidth', 1, 'color', 'k');
    colormap(flipud(redblueu))
    set(gca,'fontsize',13)
    set(gcf,'color','w')
end
set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 15, 15])

% this part will show the small hV4 data plotted in Figure 4 with cued
% activity not rotated to align at 90degrees. If rotation is ON, skip this
% plot.
if rotation == 0
    titlelist = {'Attend Left', 'Attend Right', 'Attend Up','Attend Down'};
    clims = [-0.15,0.15];
    figure;
    iter=1;
    for roi = 1
        %sgtitle(ROIs{roi})
        for cond = [3,4,1,2]
            subplot(1,num_targets,iter)
            datatp = squeeze(mean(squeeze(vf_map_to_plot(:,roi,:,:,cond)),1));
            imagesc(datatp, clims)
            if roi == 1
                title(titlelist{iter})
            end
            colormap(flipud(redblueu(120,clims)))
            %colorbar('southoutside')
            axis square
            box off
            axis off
            hold on
            h = plot(xunit, yunit, 'linewidth', 1, 'color', 'k');
            set(gca,'fontsize',25)
            iter = iter +1;
        end
        set(gcf,'color','w')
    end
    set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 2, 4])
end
