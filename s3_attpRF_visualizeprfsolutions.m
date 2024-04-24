s0_attentionpRF;
conditions = {'1','2','3','4','5'};
folderTag = 'shuffled';

for subid = 1:length(subject_list)
    subjecttm = subject_list(subid).name;
    subject = subjecttm(5:end);
    figureDir         = fullfile(path2project, 'derivatives','figures',sprintf('sub-%s',subject));
    if ~exist(figureDir, 'dir')
        mkdir(figureDir);
    end

    % convert pRFs to .mgz
    convermgz = true;
    if convermgz
        for c = 1:length(conditions)
            prfFolder         = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/%s/%s/', subject, session,folderTag, conditions{c}));
            pRFs2mgz(path2project, subject, prfFolder)
        end
    end
end
%
% for c = 1:length(conditions)
%     prfFolder         = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/%s/%s/', subject, session, folderTag, conditions{c}));
%     figuresFolder     = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/Figures/%s', subject, session, conditions{c}));
%     if ~exist(figuresFolder, 'dir')
%         mkdir(figuresFolder);
%     end
%     getpRFparameterdist(path2project, subject, prfFolder, figuresFolder)
% end
% for subid = 1:length(subject_list)
%     subjecttm = subject_list(subid).name;
%     subject = subjecttm(5:end);
%     disp(subject)
%     which_roi_boundaries = 'hand';
%     getFlatMaps(path2project,subject,session,conditions, which_roi_boundaries, folderTag)
% end
