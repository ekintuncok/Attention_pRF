s0_attentionpRF;
subject = 'wlsubj122';
sub = 3;
subject = subject_list(sub).name;

% load GLM results:
GLMfolder         = sprintf('%sderivatives/GLMdenoise/%s/%s/ses-%s/', path2project, designFolder, subject, session);
load([GLMfolder sprintf('%s_ses-%s_%s_results.mat', subject, session, designFolder)]);% this loads 'betas' and 'R2'
for idx = 1:length(betas)-2
    betas_resh(:,:,idx) = squeeze(betas{idx});
end

labels = attpRF_load_ROIs(path2project, subject);
ind_V4 = labels(:,2);
ind_V4 = ind_V4';

R2 =[1:length(R2); R2];
R2_GLM= R2(:,ind_V4);
% pick the best vertex:
[~, id] = max(R2_GLM(2,:));
best_vert = R2_GLM(1, id);

% plot the GLM estimates for the best vertex under different attenttion
% conditions
left_roi_cmap = [116,169,207]/255;
right_roi_cmap = [168, 178, 170]/255;
upper_roi_cmap = [222, 165, 146]/255;
lower_roi_cmap = [141, 107, 97]/255;

% load the pRF estimates:
prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
    sprintf('ses-%s',session), 'prfFolder', '3/');
prfFits_lh = load([prfFolder 'lh.prfFit.wholeBrain.mat']);
prfFits_rh = load([prfFolder 'rh.prfFit.wholeBrain.mat']);

% load the stimulus:
stim = prfFits_lh.results.params.stim.images_org;

x_grid = prfFits_lh.results.params.analysis.X;
y_grid = prfFits_lh.results.params.analysis.Y;

x_fits = [prfFits_lh.results.model{1}.x0, prfFits_rh.results.model{1}.x0]';
y_fits = [prfFits_lh.results.model{1}.y0, prfFits_rh.results.model{1}.y0]';

sigma_major = [prfFits_lh.results.model{1}.sigma.major, prfFits_rh.results.model{1}.sigma.major]';
sigma_minor = [prfFits_lh.results.model{1}.sigma.minor, prfFits_rh.results.model{1}.sigma.minor]';
sigma_theta = [prfFits_lh.results.model{1}.sigma.theta, prfFits_rh.results.model{1}.sigma.theta]';

vexpl_lh = 1 - (prfFits_lh.results.model{1}.rss./prfFits_lh.results.model{1}.rawrss);
vexpl_rh = 1 - (prfFits_rh.results.model{1}.rss./prfFits_rh.results.model{1}.rawrss);
vexpl = [vexpl_lh, vexpl_rh]';

rf=rfGaussian2d(x_grid,y_grid,sigma_major(best_vert),sigma_minor(best_vert),sigma_theta(best_vert)...
    ,x_fits(best_vert),y_fits(best_vert));

predicted_responses = rf'*stim;
predicted_responses = predicted_responses/norm(predicted_responses);
measured_responses = betas_resh(best_vert,:,3);
measured_responses = measured_responses/norm(measured_responses);


attpRF_visuals_plot_methods_fig;