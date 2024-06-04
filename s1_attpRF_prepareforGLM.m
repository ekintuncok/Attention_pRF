s0_attentionpRF;

for subj = 1:length(subject_list)
    subject = subject_list(subj).name(5:end);
    fprintf('%s\n', subject);
    % the input to GLMdenoise will be in nifti format. Take the gifti files of
    % the subject and convert them to nifti files. This is done on an
    % individual basis, right after the data are preprocessed for the given
    % subject.
    gii2nii(path2project, subject, sessionList);

    % create the design matrix in BIDS format to input to GLMdenoise. Again,
    % done for individual subjects:
    if strcmp(subject, 'wlsubj049')
        sessionList       = {'nyu3t01','nyu3t02','nyu3t03'};
    else
        sessionList       = {'nyu3t01','nyu3t02','nyu3t03','nyu3t04'};
    end
    BIDSformatdesign(path2project, subject, task, sessionList, designFolder);
end