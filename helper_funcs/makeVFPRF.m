function makeVFPRF(prf_params,col,plotgrid)


figure;
for r = 1:size(prf_params,1)
    xlim_min=-12;
    xlim_max=12;
    ylim_min=-12;
    ylim_max=12;

    ylim([ylim_min ylim_max])
    xlim([xlim_min xlim_max])

    x=-12:0.1:12;
    y=-12:0.1:12;
    [X,Y]=meshgrid(x,y);
    x0 = prf_params(r,1);
    y0 = prf_params(r,2);
    sigma0 = prf_params(r,3);

    w_funrion=exp(((X-x0).^2+(Y-y0).^2)/(-2*sigma0.^2));

    th = 0:pi/50:2*pi;
    xunit = (prf_params(r,3)) * cos(th)+prf_params(r,1);
    yunit = (prf_params(r,3)) * sin(th)+prf_params(r,2);

    if size(col,1) > 1
        if r == 1
            avg = plot(xunit, yunit,'Linewidth',20,'Color',col(1,:)); hold on
        else
            sing = plot(xunit, yunit,'Linewidth',20,'Color',col(2,:)); hold on
        end
    else
        if r == 1
            avg = plot(xunit, yunit,'Linewidth',20,'Color',col); hold on
        else
            sing = plot(xunit, yunit,'Linewidth',20,'Color',col); hold on
        end
    end
end

if plotgrid
    for r = [3 6 9 12]
        th = 0:pi/50:2*pi;
        xunit = r * cos(th)+0;
        yunit = r * sin(th)+0;
        h = plot(xunit, yunit,'k','Linewidth',1); hold on

        %ylabel('{\it y} position (deg)')
        %xlabel('{\it x} position (deg)')

        axis square
        ylim([-13 13])
        xlim([-13 13])
    end
end
set(gca,'TickLength', [0 0], 'LineWidth', 2)
set(gcf,'Position', [0 0 500 500])
set(gca,'FontName','roboto',    'fontsize',50)
%set(gca,'TickLength', [0.03 0.03], 'LineWidth', 2)
set(gcf,'color','w')

