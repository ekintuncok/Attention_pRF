
GLMfolder = fullfile(path2project, 'derivatives', 'GLMdenoise');
glmresults = fullfile(GLMfolder, '01', sprintf('sub-%s', subject), 'ses-nyu3t99',sprintf('sub-%s_ses-nyu3t99_01_results.mat', subject));
load(glmresults);


for idx = 1:length(betas)
    betas_resh(:,:,idx) = squeeze(betas{idx});
end

R2_GLM=R2';
[~, idx] = sort(R2_GLM,'ascend');
conditions = 1:5;

left_roi_cmap = [123,50,148]/255;
right_roi_cmap = [0,136,55]/255;
upper_roi_cmap = [44,123,182]/255;
lower_roi_cmap = [215,25,28]/255;
col = [upper_roi_cmap;lower_roi_cmap;left_roi_cmap;right_roi_cmap;[0,0,0]];
subject='sub-wlsubj141';

for conds = conditions
    % load averaged pRF estimates:
    prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
        sprintf('ses-%s',session), 'prfFolder', sprintf('%i/', conditions(conds)));

    eccen_lh = MRIread(fullfile(prfFolder,'lh.x.mgz'));
    eccen_rh = MRIread(fullfile(prfFolder, 'rh.x.mgz'));
    eccen = [eccen_lh.vol'; eccen_rh.vol'];

    angle_lh = MRIread(fullfile(prfFolder,'lh.y.mgz'));
    angle_rh = MRIread(fullfile(prfFolder, 'rh.y.mgz'));
    angle_rad = [angle_lh.vol'; angle_rh.vol'];

    size_lh = MRIread(fullfile(prfFolder,'lh.sigma.mgz'));
    size_rh = MRIread(fullfile(prfFolder, 'rh.sigma.mgz'));
    sizefit = [size_lh.vol'; size_rh.vol'];

    vexpl_lh = MRIread(fullfile(prfFolder,'lh.vexpl.mgz'));
    vexpl_rh = MRIread(fullfile(prfFolder, 'rh.vexpl.mgz'));
    vexpl = [vexpl_lh.vol'; vexpl_rh.vol'];
    
    if conds == 1
        pick_prfs = vexpl > 0.5 & R2_GLM > 5;
    end
    % pick the voxel pRF that has a high variance explained from GLM, but
    % also is going to be meaningfully visible in the figure:
    for prf_idx = 1:15
        figure(prf_idx);
        for r = [3 6 9 12]
            th = 0:pi/50:2*pi;
            xunit = r * cos(th)+0;
            yunit = r * sin(th)+0;
            h = plot(xunit, yunit,'--k','Linewidth',2); hold on
            h.Color(4) = 0.25;

            ylabel('{\it y} visual field (deg)')
            xlabel('{\it x} visual field (deg)')

            axis square
            ylim([-20 20])
            xlim([-20 20])
        end
        xlim_min=-12;
        xlim_max=12;
        ylim_min=-12;
        ylim_max=12;

        ylim([ylim_min ylim_max])
        xlim([xlim_min xlim_max])
        x=-12:0.1:12;
        y=-12:0.1:12;
        [X,Y]=meshgrid(x,y);

        hold on
        x0 = eccen(idx(prf_idx));
        y0 = angle_rad(idx(prf_idx));
        sigma0 = sizefit(idx(prf_idx));
        th = 0:pi/50:2*pi;
        xunit = sigma0 * cos(th)+x0;
        yunit = sigma0* sin(th)+y0;
        avg = plot(xunit, yunit,'-','Linewidth',3,'Color',col(conds,:));
        hold on
    end
end

