function averageBetas(path2project, subject, designFolder_source, designFolder_dest)

% average the beta weights across 5 conditions to estimate the pRFs. pRF
% solutions based on the average beta weights will be used in the model. 

GLMfolder = fullfile(path2project, 'derivatives', 'GLMdenoise');
glmresults = fullfile(GLMfolder, sprintf('%s', designFolder_source) , sprintf('sub-%s', subject), 'ses-nyu3t99',sprintf('sub-%s_ses-nyu3t99_%s_results.mat', subject, designFolder_source));
load(glmresults);

num_conditions = 5;

allbetas = zeros(size(betas{1}, 2), size(betas{1}, 4)+1, num_conditions);

for ii = 1:num_conditions
    arr = [squeeze(betas{ii}), squeeze(betas{6}(1,:,1,ii))'];
    allbetas(:,:, ii) = arr;
end

avgbetas = mean(allbetas, 3);
clear betas

session = 'nyu3t99';
betas = cell(1);
avgbetasfolder = fullfile(GLMfolder, designFolder_dest, sprintf('sub-%s', subject), sprintf('ses-%s', session),'/');
avgbetasfile = sprintf('sub-%s_ses-nyu3t99_%s_results.mat', subject, designFolder_dest);
if ~exist(avgbetasfolder, 'dir')
    mkdir(avgbetasfolder);
end
betas{1} = avgbetas;
save([avgbetasfolder, avgbetasfile], 'betas', 'R2');

GLMfolder         = sprintf('%sderivatives/GLMdenoise/%s/sub-%s/ses-%s/', path2project, designFolder_dest, subject, session);
betas2nii(path2project, GLMfolder, subject, session, designFolder_dest);
