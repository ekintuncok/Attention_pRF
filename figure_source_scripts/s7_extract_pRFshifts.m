s0_attentionpRF;
shift_data = [];

%cond_check = input('randomize the location column idx?');
cond_check = 0;
if cond_check == 0
    designFolder = 'main';
    folderTag = 'main';
    cond_tag = '';
else
    designFolder = 'shuffled';
    folderTag = 'shuffled';
    cond_tag = '_shuffled';
end

disp(folderTag)

for sub = 1:length(subject_list)
    subject = subject_list(sub).name;
    disp(subject)

    labels = attpRF_load_ROIs(path2project, subject);

    retinotopy_conditions = {'1', '2', '3', '4', '5'};
    GLMfolder         = fullfile(path2project, sprintf('derivatives/GLMdenoise/%s/%s/ses-%s/', designFolder, subject, session));
    load([GLMfolder sprintf('%s_ses-%s_%s_results.mat', subject, session, designFolder)]);% this loads 'betas' and 'R2'

    R2 = R2';

    subject_shift_data = [];
    for roi = 1:size(labels,2)

        currROI = labels(:,roi);
        indices = currROI ~= 0;

        disp(ROIs{roi})
        roi_shift_data = zeros(sum(indices), 23);
        roi_shift_data(:,1) = sub;
        roi_shift_data(:,2) = roi;
        roi_shift_data(:,23) = R2(indices);
        for ret_shift_data_idx = 1:length(retinotopy_conditions)

            prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
                sprintf('ses-%s',session), sprintf('%s',folderTag), sprintf('%s/',retinotopy_conditions{ret_shift_data_idx}));
            vexpl_lh = MRIread(fullfile(prfFolder, 'lh.vexpl.mgz'));
            vexpl_rh = MRIread(fullfile(prfFolder, 'rh.vexpl.mgz'));
            vexpl = [vexpl_lh.vol vexpl_rh.vol]';

            eccen_lh = MRIread(fullfile(prfFolder, 'lh.eccen.mgz'));
            eccen_rh = MRIread(fullfile(prfFolder, 'rh.eccen.mgz'));
            eccen = [eccen_lh.vol eccen_rh.vol]';

            x_vals_lh = MRIread(fullfile(prfFolder,'lh.x.mgz'));
            x_vals_rh = MRIread(fullfile(prfFolder,'rh.x.mgz'));

            y_vals_lh = MRIread(fullfile(prfFolder,'lh.y.mgz'));
            y_vals_rh = MRIread(fullfile(prfFolder,'rh.y.mgz'));

            x_vals = [x_vals_lh.vol x_vals_rh.vol]';
            y_vals = [-1*y_vals_lh.vol -1*y_vals_rh.vol]';

            roi_shift_data(:,3*ret_shift_data_idx) = x_vals(indices);
            roi_shift_data(:,3*ret_shift_data_idx+1) = y_vals(indices);
            roi_shift_data(:,3*ret_shift_data_idx+2) = eccen(indices);
            roi_shift_data(:,ret_shift_data_idx+17) = vexpl(indices);
        end
        subject_shift_data = cat(1,subject_shift_data, roi_shift_data);
    end
    shift_data = cat(1,shift_data, subject_shift_data);
end

%comp_type = input('compare against focal or distributed?\n', 's');
comp_type = 'distributed';
if strcmp(comp_type, 'focal')
    col_indices_x = 3:3:13;
    col_indices_y = 4:3:13;
elseif strcmp(comp_type, 'distributed')
    col_indices_x = 15;
    col_indices_y = 16;
end

% Threshold the data:
eccen_low_lim = 0.5;
eccen_up_lim  = 6;

r2_thresh = 0.25;
indices = sum(ismember(shift_data(:,5:3:17) < eccen_up_lim, 0),2) == 0 & sum(ismember(shift_data(:,5:3:17) > eccen_low_lim, 0),2) == 0 & ...
    sum(ismember(shift_data(:,18:23) > r2_thresh, 0),2) == 0;

shift_data_thresholded = shift_data(indices,:);
target_coords = [0,6;0,-6;-6,0;6,0];
change_in_distance = [];

% Calculate distance changes:
distance_in_attend_target = zeros(length(shift_data_thresholded), num_targets);
distance_in_distributed = zeros(length(shift_data_thresholded), num_targets);
loc = [3, 6, 9, 12];

for location = 1:num_targets
    attend_target_x =  shift_data_thresholded(:, loc(location));
    attend_target_y =  shift_data_thresholded(:, loc(location)+1);

    attend_out_x = mean(shift_data_thresholded(:, [setdiff(col_indices_x, loc(location))]),2);
    attend_out_y = mean(shift_data_thresholded(:, [setdiff(col_indices_y, loc(location)+1)]),2);

    distance_in_attend_target(:,location)  = sqrt((target_coords(location,1) - attend_target_x).^2 + (target_coords(location,2) - attend_target_y).^2);
    distance_in_distributed(:,location) = sqrt((target_coords(location,1) - attend_out_x).^2    + (target_coords(location,2) - attend_out_y).^2);
end

% % Take the mean distance across voxels:
distance_in_attend_target = [shift_data_thresholded(:,1:2), (distance_in_attend_target)];
distance_in_att_distributed = [shift_data_thresholded(:,1:2), (distance_in_distributed)];

save(fullfile(path2project, sprintf('derivatives/prf_shift_data/distance_in_focal%s.mat', cond_tag)), 'distance_in_attend_target', '-v7.3');
save(fullfile(path2project, sprintf('derivatives/prf_shift_data/distance_in_distributed%s.mat', cond_tag)), 'distance_in_att_distributed', '-v7.3');
