s0_attentionpRF;

for sub_idx = 1:length(subject_list)
    subject = subject_list(sub_idx).name;
    disp(subject)
    %set directories:
    ts_dir = fullfile(path2project,'derivatives', 'fmriprep', sprintf('%s',subject), 'ses-nyu3t99','func/');
    num_runs = (size(dir(ts_dir),1)-2)/2;
    prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
        sprintf('ses-%s',session), 'prfFolder', 'avg/');

    [eccen, angle] = attpRF_load_pRFs(prfFolder);
    labels         = attpRF_load_ROIs(path2project, subject);

    % create cortical ROIs around the target representation:
    polar_angle_limits = {[60, 120]; [240, 300]; [150, 210]; [0, 30, 330, 360]};
    eccen_limits = [4, 7];
    timeseries_concatenated = [];
    roi_information = [];
    % get the current ROI indices:
    for run_idx = 1:num_runs
        fprintf('Run: %i/%i\n', run_idx, num_runs)
        runs = dir(fullfile(ts_dir, sprintf('*run-%i_*', run_idx)));
        % load and concatenate the raw timeseries:
        timeseries_lh = MRIread(fullfile(ts_dir, runs(1).name));
        timeseries_rh = MRIread(fullfile(ts_dir, runs(2).name));
        timeseries = [squeeze(timeseries_lh.vol); squeeze(timeseries_rh.vol)];

        % take the difference from the first TR to produce a stationary
        % timeseries at each vertex:
        %timeseries_diff = timeseries(:,2:end)-timeseries(:,1:end-1);

        % convert to percent change:
        percent_change = (timeseries./mean(timeseries, 2, 'omitnan')*100)-100;

        % detrend the timeseries data
        detrended_timeseries = detrend_timeseries(percent_change);
        timeseries_run = [];

        for roi = 1:size(labels, 2)
            indices = labels(:,roi);
            if run_idx == 1
                target_mask = attpRF_get_target_ROIs(indices, eccen, angle, eccen_limits, polar_angle_limits);
                curr_roi_information = [roi*ones(size(detrended_timeseries(indices,:),1),1), target_mask];
                %curr_roi_information = [roi*ones(size(detrended_timeseries(indices,:),1),1), eccen(indices), angle(indices)];
                roi_information = cat(1, roi_information, curr_roi_information);
            end
            roi_timeseries = detrended_timeseries(indices,:);
            timeseries_run = cat(1,timeseries_run,roi_timeseries);
            roi_timeseries = [];
        end
        timeseries_concatenated = cat(2, timeseries_concatenated, timeseries_run);
    end
    subj_timeseries_data = [sub_idx*ones(length(roi_information),1), roi_information, timeseries_concatenated];
    save(fullfile(path2project, sprintf('derivatives/ROI_timeseries/%s_raw_ROI_timeseries.mat', subject)), 'subj_timeseries_data', '-v7.3')
    subj_timeseries_data = [];
end

