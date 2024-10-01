s0_attentionpRF;
target_output_dir = fullfile(path2project, 'derivatives','amplitude_data/');

% create the grid for interpolation:
stim_ecc = 10;
conditions = 1:4;
[xq,yq] = meshgrid(-12:.1:12, -12:.1:12);
yq = -1*yq;
flat_x = reshape(xq, [length(xq)*length(xq), 1]);
flat_y = reshape(yq, [length(xq)*length(xq), 1]);
which_betas = 'all';
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

if strcmp(which_betas, 'all')
    save([target_output_dir,'amplitude_change_full_map.mat'], 'vf_map_to_plot', '-v7.3');
elseif strcmp(which_betas, 'null')
    save([target_output_dir,'amplitude_change_full_map_null_trials.mat'], 'vf_map_to_plot', '-v7.3');
end
