s0_attentionpRF;
% create the grid for interpolation:
stim_ecc = 10;
conditions = 1:4;
[xq,yq] = meshgrid(-12:.1:12, -12:.1:12);
yq = -1*yq;
flat_x = reshape(xq, [length(xq)*length(xq), 1]);
flat_y = reshape(yq, [length(xq)*length(xq), 1]);

% mask the coordinates with an ecc of larger tha the given stimulus
% eccentricity
eccen_vals = sqrt(flat_x.^2 + flat_y.^2);
eccen_mask = eccen_vals < stim_ecc;
eccen_mask_2d = reshape(eccen_mask, [length(xq),length(xq)]);
vf_map_to_plot = zeros(length(subject_list), length(ROIs), length(xq),length(yq), length(conditions));
rotation = 1;
for sub = 1:length(subject_list)
    subject = subject_list(sub).name;
    disp(subject)
    labels = attpRF_load_ROIs(path2project, subject);
    for roi = 1:size(labels,2)
        disp(ROIs{roi})
        currROI = labels(:,roi);
        designFolder = 'main';
        vf_map_to_plot(sub, roi, :, :, :) = attpRF_grid_amplitude_data(currROI, path2project, subject, session, designFolder, xq, yq, eccen_mask_2d, rotation);
    end
end

%% visualize
th = 0:pi/50:2*pi;
xunit = length(xq)/4 * cos(th) + length(xq)/2;
yunit = length(yq)/4 * sin(th) + length(yq)/2;

%visualize the averaged focal vs distributed spread:
clims = [-0.15,0.15];
figure;
for roi = 1:length(ROIs)
    subplot(2, 3,roi)
    imagesc(mean(squeeze(mean(vf_map_to_plot(:,roi,:,:,:),1)),3),clims);
    axis square
    box off
    axis off
    hold on
    plot(xunit, yunit, 'linewidth', 1, 'color', 'k');
    colormap(flipud(redblueu))
    set(gca,'fontsize',13)
    set(gcf,'color','w')
end
ha=get(gcf,'children');
set(ha(1),'position',[.5 .25 .4 .4])
set(ha(2),'position',[.40 .25 .4 .4])
set(ha(3),'position',[.3 .25 .4 .4])
set(ha(4),'position',[.2 .25 .4 .4])
set(ha(5),'position',[.1 .25 .4 .4])
set(ha(6),'position',[.0 .25 .4 .4])
%colorbar('southoutside')
set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 6, 4])

% this part will show the small hV4 data plotted in Figure 4 with cued
% activity not rotated to align at 90degrees. If rotation is ON, skip this
% plot.
if rotation == 0
    titlelist = {'Attend Left', 'Attend Right', 'Attend Up','Attend Down'};
    clims = [-0.15,0.15];
    figure;
    iter=1;
    for roi = 4
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
