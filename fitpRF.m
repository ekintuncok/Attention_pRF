maindir           = '/Volumes/server/Projects/attentionpRF/Simulations/';
% load the stim file
load([fullfile(maindir, 'stimfiles/') 'stim.mat'])
stim = stim(:,:,1:end-1);

% maximum ecc
stim_ecc = 12.4;
step_size = stim_ecc/25;

rF_size_major = step_size:step_size:stim_ecc;
x0 = -stim_ecc:step_size:stim_ecc;
y0 = -stim_ecc:step_size:stim_ecc;

RFIndices = combvec(rF_size_major,x0,y0);
Ecc_lim = sqrt(RFIndices(2,:).^2+RFIndices(2,:).^2);
mask = Ecc_lim < 12.4;
RFIndices = RFIndices(:,mask);

[X, Y] = meshgrid(-stim_ecc:step_size:stim_ecc);
rfs_nofit=rfGaussian2d(X(:),Y(:),RFIndices(1,:),RFIndices(1,:),0,RFIndices(2,:),RFIndices(3,:));
% rfsimg = reshape(rfs_nofit,[size(X,1) size(X,1) size(rfs_nofit,2)]);
% close all;for s = 1 : 100: size(rfsimg,3); imagesc(rfsimg(:,:,s)); pause(0.05); end

% reduce the size of the stim input to the spatial grid defined by x:
newimage = zeros([size(X,1) size(X,1) size(stim,3)]);
for s = 1:size(stim,3)
    newimage(:,:,s) = imresize(stim(:,:,s),[size(X,1) size(X,1)],'nearest');
end

% vectorize the stim input:
newim1d = reshape(newimage,[size(newimage,1)*size(newimage,2) size(stim,3)]);
% prediction is the product of the stim matrix with RFs
pred = rfs_nofit'*newim1d;
% get the beta vals for regions of interest
datafiles = dir(fullfile(maindir, 'fitData','*.mat'));
load([datafiles.folder '/' datafiles.name]);
% preallocate
sigma = zeros(size(data,1),size(data,3));
pa    = zeros(size(data,1),size(data,3));
ecc   = zeros(size(data,1),size(data,3));
R     = zeros(size(data,1),size(data,3));
xCoord = zeros(size(data,1),size(data,3));
yCoord = zeros(size(data,1),size(data,3));
for attCond = 1:size(data,3)
    for v = 1:size(data)
        
        mybeta = data(v,:,attCond);
        
        % Calculates the correlation between the actual beta weights and
        % the predicted beta weights
        [val,ind] = max(corr(mybeta',pred'));
        
        % if the correlation is lower than 0.2, fill in NaNs
        if val < 0.2
            sigma(v,attCond) = NaN;
            pa(v,attCond) =  NaN;
            ecc(v,attCond) = NaN;
            R(v,attCond) = NaN;
        else
            xCoord(v,attCond) = RFIndices(2,ind);
            yCoord(v, attCond) = RFIndices(3,ind);
            
            sigma(v,attCond) = RFIndices(1,ind);
            % convert the coordinate vals to polar angle and eccentricity
            pa(v,attCond) =  atan2(-xCoord(v,attCond),yCoord(v,attCond));
            ecc(v,attCond) = sqrt(xCoord(v,attCond).^2+yCoord(v,attCond).^2);
            % saves the correlation coeff for each voxel
            R(v,attCond) = val;
        end
    end
end
figure(1)
plot(1:48,mybeta)
hold on
plot(1:48,pred(ind,:))