s0_attentionpRF;
%conditions = {'1','2','3','4','5'};
conditions = {'avg'};

folderTag = 'main'; % or 'shuffled'

for subid = 1:length(subject_list)
    subjecttm = subject_list(subid).name;
    subject = subjecttm(5:end);

    % convert pRFs to .mgz
    convermgz = true;
    if convermgz
        for c = 1:length(conditions)
            prfFolder         = fullfile(path2project, 'derivatives', 'prfs', sprintf('/sub-%s/ses-%s/%s/%s/', subject, session,folderTag, conditions{c}));
            pRFs2mgz(path2project, subject, prfFolder)
        end
    end
end
