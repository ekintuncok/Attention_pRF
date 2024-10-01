function visual_field_map = attpRF_grid_amplitude_data(currROI, path2project, subject, session, designFolder, x_grid, y_grid, masked_grid, rotation, which_betas)

attend_up = 1;
attend_down = 2;
attend_left = 3;
attend_right = 4;
conditions = [attend_up, attend_down, attend_left, attend_right];
target_to_center = 90;
target_angle_location = [90, 270, 180, 0];

% should we rotate the maps or return the original maps?
if rotation
    target_angle_shift_deg = target_angle_location-target_to_center;
else
    target_angle_shift_deg = [0, 0, 0, 0];
end

% load the GLM results:
GLMfolder         = sprintf('%s/derivatives/GLMdenoise/%s/%s/ses-%s/', path2project, designFolder, subject, session);
prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
    sprintf('ses-%s',session), 'main', 'avg/');

% load the pRF results:
load([GLMfolder sprintf('%s_ses-%s_%s_results.mat', subject, session, designFolder)]);% this loads 'betas' and 'R2'

if strcmp(which_betas, 'all')
    for idx = 1:length(betas)-2
        thresholded_betas(:,:,idx) = squeeze(betas{idx});
    end
    thresholded_betas(:,2,:) = squeeze(betas{6}); % null trial estimates
elseif strcmp(which_betas, 'null')
    thresholded_betas = squeeze(betas{6}); % null trial estimates
end

R2 = R2';
indices = currROI ~= 0 & R2 > 3;

[eccen, pangle_to_shift] = attpRF_load_pRFs(prfFolder, 'polar');

visual_field_map = zeros(length(x_grid), length(y_grid), length(conditions));
for conds = 1:length(conditions)
    shifted_pangle = pangle_to_shift - target_angle_shift_deg(conds);
    shifted_pangle_radians = deg2rad(shifted_pangle);
    [shifted_X, shifted_Y] = pol2cart(shifted_pangle_radians, eccen);
    if strcmp(which_betas, 'all')
        betas = mean(thresholded_betas(indices,:,conds),2)-mean(thresholded_betas(indices,:,5),2);
    elseif  strcmp(which_betas, 'null')
        betas = mean(thresholded_betas(indices,conds),2)-mean(thresholded_betas(indices,5),2);
    end
    betas = double(betas);
    interpolated_visual_field_map = griddata(shifted_X(indices), shifted_Y(indices), betas, x_grid, y_grid);
    interpolated_visual_field_map = interpolated_visual_field_map.*masked_grid;
    interpolated_visual_field_map(isnan(interpolated_visual_field_map)) = 0;
    visual_field_map(:,:,conds) = interpolated_visual_field_map;
end




