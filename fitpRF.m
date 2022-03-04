clc
clear

% Set directories
setenv('SUBJECTS_DIR','/Volumes/server/Projects/attentionpRF/BIDS/derivatives/freesurfer');  %
projectDir        = '/Volumes/server/Projects/attentionpRF/BIDS';
stimDir           = '/Volumes/server/Projects/attentionpRF/Stim';

subject           = 'wlsubj127';
session           = 'nyu3t01';
tasks             = 'prf';
designFolder      = '01';

resultsDir        = sprintf([projectDir '/derivatives/GLMdenoise/%s/sub-%s/ses-%s/prfFolder'], designFolder, subject, session);

% load the stim file
load(sprintf([stimDir '/sub-%s_ses-%s_task-%s_stim.mat'], subject, session, tasks))
stim = mappingStimMask;

% maximum ecc
stim_ecc = 12.4;
step_size = stim_ecc/25;

rF_size_major = step_size:step_size:stim_ecc;
x0 = -stim_ecc:step_size:stim_ecc;
y0 = -stim_ecc:step_size:stim_ecc;

RFIndices = combvec(rF_size_major,x0,y0);
Ecc_lim = sqrt(A(2,:).^2+A(2,:).^2);
mask = Ecc_lim < 12.4;
RFIndices = RFIndices(:,mask);

[X, Y] = meshgrid(-stim_ecc:step_size:stim_ecc);
rfs_nofit=rfGaussian2d(X(:),Y(:),RFIndices(1,:),RFIndices(1,:),0,RFIndices(2,:),RFIndices(3,:));
% rfsimg = reshape(rfs,[size(X,1) size(X,1) size(rfs,2)]);
% close all;for s = 1 : 100: size(rfsimg,3); imagesc(rfsimg(:,:,s)); pause(0.05); end

newimage = zeros([size(X,1) size(X,1) size(stim,3)]);

for s = 1:size(stim,3)
    newimage(:,:,s) = imresize(stim(:,:,s),[size(X,1) size(X,1)],'nearest');  
end

newim1d = reshape(newimage,[size(newimage,1)*size(newimage,2) size(stim,3)]);
hemi = {'lh';'rh'};
cd(resultsDir);
for h = 1:length(hemi)
    
    % prediction is the product of the stim matrix with RFs
    pred = rfs'*newim1d;
    % get the beta vals for regions of interest 
    beta_lh = MRIread(sprintf('/Volumes/server/Projects/attentionpRF/BIDS/derivatives/GLMdenoise/%s/sub-%s/ses-%s/mgzfiles/%s.modelmd.mgz',...
        designFolder, subject, session, hemi{h}));
    V1 =  read_label('sub-wlsubj127',sprintf('%s.V1_exvivo',hemi{h}));
    V1 = V1(:,1)+1;
    
    V2 =  read_label('sub-wlsubj127',sprintf('%s.V2_exvivo',hemi{h}));
    V2 = V2(:,1)+1;
    
    rois = [V1;V2];
    
    beta_lh_V1 = squeeze(beta_lh.vol(rois,:,:,:));
    % preallocate
    sigma = zeros(size(beta_lh_V1,1),1);
    pa = zeros(size(beta_lh_V1,1),1);
    ecc = zeros(size(beta_lh_V1,1),1);
    R = zeros(size(beta_lh_V1,1),1);
    
    for v = 1:size(beta_lh_V1)
        
        mybeta = beta_lh_V1(v,:);
        
        % Calculates the correlation between the actual beta weights and
        % the predicted beta weights
        [val,ind] = max(corr(mybeta',pred'));
        
        % if the correlation is lower than 0.2, fill in NaNs
        if val < 0.2
            sigma(v) = NaN;
            pa(v) =  NaN;
            ecc(v) = NaN;
            R(v) = NaN;     
        else
            tmpx = RFIndices(2,ind);
            tmpy = RFIndices(3,ind);  
            sigma(v) = RFIndices(1,ind);
            % convert the coordinate vals to polar angle and eccentricity
            pa(v) =  atan2(-tmpy,tmpx);
            ecc(v) = sqrt(tmpx.^2+tmpy.^2);
            % saves the correlation coeff for each voxel
            R(v) = val;
        end
    end
    
    mytmp = MRIread(sprintf('/Volumes/server/Projects/attentionpRF/BIDS/derivatives/GLMdenoise/%s/sub-%s/ses-%s/mgzfiles/%s.R2.mgz',...
        designFolder, subject, session, hemi{h}));
    tmp = zeros(size(mytmp.vol));

    tmp(rois,1) = rad2deg(pa);
    mytmp.vol = tmp;
    MRIwrite(mytmp,sprintf('%s.test_pa.mgz',hemi{h}));
    tmp(rois,1) = ecc;
    mytmp.vol = tmp;
    MRIwrite(mytmp,sprintf('%s.test_ecc.mgz',hemi{h}));
    tmp(rois,1) = R;
    mytmp.vol = tmp;
    MRIwrite(mytmp,sprintf('%s.test_R.mgz',hemi{h}));
    
end

