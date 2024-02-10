s0_attentionpRF;

for sub = 1:length(subject_list)
    subjecttemp = subject_list(sub).name;
    subject = subjecttemp(5:end);
    disp(subject)

    designFolder_source = 'main';

    GLMfolder         = sprintf('%sderivatives/GLMdenoise/%s/sub-%s/ses-%s/', path2project, designFolder_source, subject, session);

    % convert percent BOLD change estimates to nifti for faster pRF fitting:
    betas2nii(path2project, GLMfolder, subject, session, designFolder_source);

    % use the existing GLM estimates, but average them across attention
    % conditions and covert them to the proper format for the averaged pRF
    % fits:
    designFolder_dest = 'avg_betas';

    averageBetas(path2project, subject, designFolder_source, designFolder_dest);
end