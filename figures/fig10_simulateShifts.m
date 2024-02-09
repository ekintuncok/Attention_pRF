load('/Volumes/server/Projects/attentionpRF/Stim/stim.mat');
px = size(stim, 2);
t = 0:size(stim,3)-1;
[x,y] = meshgrid(linspace(-12,12,px));
sigma = [1.5, 4]; % prf size at 6 deg
shiftsize = [-0.04, -0.3]; % shift of prf from attetnion in deg
amp0 = [0.2, 0.3]; % BOLD amplitude in neutral condition
ampDelta = [0.07, 0.04]; % change in ampltidue from netural to focal
x0 = -7; y0 = 0;
figure;
for ii = 1:length(sigma)
    % neutral pRF
    prf0 = exp(-1/2*(((x-x0).^2+(y-y0).^2)/sigma(ii)^2));
    % focal pRF
    x1 = x0+shiftsize(ii);
    y1 = y0;
    prf1 = exp(-1/2*(((x-x1).^2+(y-y0).^2)/sigma(ii)^2));
    response0_tmp = reshape(prf0, 1080*1080,1)'* reshape(stim, 1080*1080,[]);
    response1_tmp = reshape(prf1, 1080*1080,1)'* reshape(stim, 1080*1080,[]);
    response0(ii,:) = response0_tmp / max(response0_tmp) * amp0(ii);
    response1(ii,:) = response1_tmp / max(response1_tmp) * amp0(ii) + ampDelta(ii);
    subplot(1,2,ii)
    plot(t, response0(ii,:), '-','color', [127,127,127]/255,'LineWidth',1.75)
    hold on
    plot(t, response1(ii,:), '-','color',[204, 95, 90]/255,'LineWidth',1.75)
    hold on
    plot(t, response1(ii,:)-response0(ii,:)-0.1, 'k','LineWidth',1.75)
    hold on
    plot(t, ampDelta(ii)*ones(size(t))-0.1, 'color',[202, 119, 75]/255, 'LineWidth',1.75)
    if ii == 1
        xlabel('Mapping stimulus position')
        ylabel('% BOLD change')
    end
    ylim([-0.1,0.35])
    xlim([0,t(end)])
    set(gca,'TickLength', [0.015 0.015], 'LineWidth', 2)
    axis square
    set(gca, 'fontname', 'Arial','FontSize', 18);

end

set(gcf, 'color','w')
