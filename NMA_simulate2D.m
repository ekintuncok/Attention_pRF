% function [X, Y, inputStim, sptPopResp, predneuralweights] = NMA_simulate2D(maindir, params)

mxecc       = params(1);
attgain     = params(2);
attx0       = params(3);
atty0       = params(4);
attsd       = params(5);
sigmaNorm   = params(6);
visualize   = params(7);

%% Space (1D)
step_size = mxecc/25;
ecc = linspace(-5,5,64);
[X,Y] = meshgrid(ecc);

%% Stimuli
stimtemp = load([fullfile(maindir, 'stimfiles/') 'stim.mat']);
stim    = stimtemp.stim(:,:,1:end-1);
stim    = logical(stim);
% pad stimulus with zeros to avoid edge artifacts
inputStim = zeros(size(X,1),size(X,1),size(stim,3));
fullSize = size(X,1);
stimSize = fullSize-(0.25*fullSize);
imStart = fullSize/2-(stimSize/2);
imEnd = imStart+stimSize-1;
imIdx = imStart:imEnd;
for s = 1:size(stim,3)
    inputStim(imIdx,imIdx,s) = imresize(stim(:,:,s),[stimSize stimSize],'nearest');
end

%inputStim = zeros(size(X,1),size(X,1),size(stim,3));
%for s = 1:size(stim,3)
    %inputStim(:,:,s) = imresize(stim(:,:,s),[size(X,1) size(X,1)],'nearest');
%end

nCenters    = size(inputStim,1);
x           = linspace(-8.8,8.8,nCenters);
y           = linspace(-8.8,8.8,nCenters);

try
    nPRFs       = size(combvec(x,y),2);
    stimdrivenRFs(1:2,:) = combvec(x,y);
catch
    nPRFs       = size(CombVec(x,y),2);
    stimdrivenRFs = CombVec(x,y);
end

% If we keep the x- and y- axes range (look a line up) at [-10 to 10] our
% max eccentricity goes up to 14 degrees. Now we need to assign our sigma
% value accordingly.

for pRFInd = 1:nPRFs
    currCenter = stimdrivenRFs(1:2,pRFInd);
    % calculate the euclidean distance from the center of gaze (origin) to
    % assign the sigma value based on the distance. The distance here is a
    % proxy of eccentricity (it's actually the literal definition of it!)
    eccen = sqrt(currCenter(1).^2 + currCenter(2).^2);
    stimdrivenRFs(3,pRFInd) = 0.05 + 0.1*eccen;
end

%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;

%% Stimulus and Suppressive Drive
stimdrive = zeros(size(stimdrivenRFs,2),size(inputStim,3));
numeratorVec = zeros(size(stimdrivenRFs,2),size(inputStim,3));
suppressivedriveRF = zeros(size(stimdrivenRFs,2),size(stimdrivenRFs,2),size(inputStim,3));
for ii = 1:size(inputStim,3)
    for rfind = 1:size(stimdrivenRFs,2)
        % get the stim driven RF
        RF = exp(-((X-(stimdrivenRFs(1,rfind))).^2 + ...
            (Y-(stimdrivenRFs(2,rfind))).^2)./(2*(stimdrivenRFs(3,rfind))).^2);
        RF = RF./sum(RF(:));
        
        % get the stimulus vectorized
        stim = inputStim(:,:,ii);
        stim = stim(:);
        stimdrive(rfind, ii) = RF(:)'*stim;
    end
    numeratorVec(:,ii) = stimdrive(:,ii).*attfield(:);
    for rfsuppind = 1:size(stimdrivenRFs,2)
        RFnorm = exp(-((X-(stimdrivenRFs(1,rfsuppind))).^2 + ...
            (Y-(stimdrivenRFs(2,rfsuppind))).^2)./(2*2*(stimdrivenRFs(3,rfsuppind))).^2);
        RFnorm = RFnorm./sum(RFnorm(:)); % unit volume
        suppressivedriveRF(:, rfind, ii) = RFnorm(:).*numeratorVec(:,ii); 
    end
end

for stimind = 1:size(inputStim,3)   
    for rfind = 1:size(stimdrivenRFs,2)
        thisRFsupp(:,rfind) = squeeze(suppressivedriveRF(:,rfind,stimind));
        suppressivedriveImg(:,:,rfind) = reshape(thisRFsupp(:,rfind), [size(inputStim,1), size(inputStim,2)]);
    end
    suppressivedrivepop(:,:,stimind) = sum(suppressivedriveImg, 3);
end

stimdriveIm = zeros(size(inputStim,1),size(inputStim,2),size(inputStim,3));
numeratorIm = zeros(size(inputStim,1),size(inputStim,2),size(inputStim,3));

for s = 1:size(stimdrive,2)
    stimdriveIm(:,:,s) = reshape(stimdrive(:,s), [size(inputStim,1) size(inputStim,2)]);
    numeratorIm(:,:,s) = reshape(numeratorVec(:,s), [size(inputStim,1) size(inputStim,2)]);
end
close all
figure
for s = 1:size(stimdrive,2)
    subplot(1,3,1)
    imagesc(stimdriveIm(:,:,s))
    title('Stimulus drive')
    subplot(1,3,2)
    imagesc(numeratorIm(:,:,s))
    title('Numerator (stimulus drive.*attfield)')
    subplot(1,3,3)
    imagesc(suppressivedrivepop(:,:,s))
    title('Suppressive drive')
    pause(0.5)
end

%% population response
sptPopResp = numeratorIm ./ (suppressivedrivepop + sigmaNorm);
if visualize
    close all, for ii = 1:size(sptPopResp,3), imagesc(sptPopResp(:,:,ii)), pause(0.5), end
end
%close all, for ii = 1:size(sptPopResp,3), imagesc(sptPopResp(:,:,ii)), pause(0.5), end

% pooledPopResp = convn(sptPopResp, RFsumm, 'same');
% Go across time for a specific location in the pop response,let's say x =
% 1, y = 2.
predneuralweights = reshape(sptPopResp,[size(sptPopResp,1)*size(sptPopResp,2) size(sptPopResp,3)]);
% predsummedweights = reshape(pooledPopResp,[size(pooledPopResp,1)*size(pooledPopResp,2) size(pooledPopResp,3)]);
% end
