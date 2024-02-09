s0_attentionpRF;

% the input to GLMdenoise will be in nifti format. Take the gifti files of
% the subject and convert them to nifti files. This is done on an
% individual basis, right after the data are preprocessed for the given
% subject.
gii2nii(path2project, subject, sessionList);

% create the design matrix in BIDS format to input to GLMdenoise. Again,
% done for individual subjects:
BIDSformatdesign(path2project, subject, task, sessionList, designFolder);
