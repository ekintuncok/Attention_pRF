%% Attention pRF: script to quantify GLM and pRF model performance:

s0_attentionpRF;
designFolder = 'avg_betas';

num_targets = 4;
prf_labels = {'1','2','3','4','5','avg'};

prf_folder_name = 'prfFolder_2';

% preallocate:
med_GLM_R2 = zeros(length(subject_list), length(ROIs));
med_pRF_R2 = zeros(length(subject_list), length(ROIs), num_targets+1);

for sub = 1:length(subject_list)
    figure(sub)
    subject = subject_list(sub).name;
    disp(subject)
    % load subjects GLM results
    GLMfolder         = sprintf('%sderivatives/GLMdenoise/%s/%s/ses-%s/', path2project, designFolder, subject, session);
    load([GLMfolder sprintf('%s_ses-%s_%s_results.mat', subject, session, designFolder)]);% this loads 'betas' and 'R2'

    % load ROI information:
    labels = attpRF_load_ROIs(path2project, subject);

    vexpl = [];
    for cond = 1:num_targets+2
        % load pRF estimates:
        prfFolder = fullfile(path2project, 'derivatives', 'prfs', sprintf('%s',subject),...
            sprintf('ses-%s',session), sprintf('%s', prf_folder_name), sprintf('%s/', prf_labels{cond}));

        vexpl_lh = MRIread(fullfile(prfFolder, 'lh.vexpl.mgz'));
        vexpl_rh = MRIread(fullfile(prfFolder, 'rh.vexpl.mgz'));
        vexpl(:, cond) = [vexpl_lh.vol vexpl_rh.vol]';
    end

    for roi = 1:size(labels,2)
        roi_indices = labels(:,roi);
        med_GLM_R2(sub, roi) = median(R2(roi_indices));

        for cond = 1:num_targets+2
            med_pRF_R2(sub, roi, cond) = median(vexpl(roi_indices, cond), 'omitnan');
        end
        % average_att_r2 = nanmean(vexpl(roi_indices, 1:5),2);
        % subplot(2, 3, roi)
        % histogram(vexpl(roi_indices, 6) - average_att_r2)
        % xlabel('average pRF R2 - averaged attention pRF R2')
        % hold on
        % xline(0)
    end
end

med_pRF_R2(1, 4:end, :) = NaN;
med_GLM_R2(1, 4:end) = NaN;

avg_roi_r2 =  squeeze(nanmean(med_pRF_R2, 1)*100);
figure;
bar(avg_roi_r2)
legend('Attend up', 'Attend down', 'Attend left','Attend right', 'Neutral', 'Average')
ylabel('R2 of the pRF model')
