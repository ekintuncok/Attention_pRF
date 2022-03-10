function [X, Y, stim, sptPopResp, pooledPopResp, predneuralweights, predsummedweights] = NMA_simulate2D(maindir, params)

mxecc       = params(1);
RFsd        = params(2);
attgain     = params(3);
attx0       = params(4);
atty0       = params(5);
attsd       = params(6);
pooledPopRespsd = params(7);
sigmaNorm       = params(8);

%% Space (1D)
step_size = mxecc/50;
[X,Y] = meshgrid(-mxecc:step_size:mxecc);

%% Stimuli
load([fullfile(maindir, 'stimfiles/') 'stim.mat'])
stim    = stim(:,:,1:end-1);
stim    = logical(stim);

inputStim = zeros(size(X,1),size(X,1),size(stim,3));
for s = 1:size(stim,3)
    inputStim(:,:,s) = imresize(stim(:,:,s),[size(X,1) size(X,1)],'nearest');
end

%% Neural RFs
RFsupp = exp(- ((X-0).^2 + (Y-0).^2)./(2*1.5*RFsd).^2);
%% Voxel pooledPopResp (across neurons)
RFsumm = exp(-((X-0).^2 +(Y-0).^2)./(2*pooledPopRespsd).^2); %%% keep in mmind
nCenters    = size(inputStim,1);
x           = linspace(-8.8,8.8,nCenters); 
y           = linspace(-8.8,8.8,nCenters);
nPRFs       = size(combvec(x,y),2);
numSigmas   = 10;
sigma       = linspace(0.1,5,numSigmas); % in degrees of visual field
maxEccen    = sqrt(x(1).^2 + y(1).^2);
sampleEccen = linspace(0,maxEccen,numSigmas);

% If we keep the x- and y- axes range (look a line up) at [-10 to 10] our
% max eccentricity goes up to 14 degrees. Now we need to assign our sigma
% value accordingly. 

stimdrivenRFs   = zeros(3,size(combvec(x,y),2));
stimdrivenRFs(1:2,:) = combvec(x,y);

for pRFInd = 1:nPRFs
    currCenter = stimdrivenRFs(1:2,pRFInd);
    % calculate the euclidean distance from the center of gaze (origin) to
    % assign the sigma value based on the distance. The distance here is a
    % proxy of eccentricity (it's actually the literal definition of it!)
    eccen = sqrt(currCenter(1).^2 + currCenter(2).^2);
    stimdrivenRFs(3,pRFInd) = 0.05 + 0.1*eccen;
    continue
    %for eccenInd = 1:length(sampleEccen)
        %thisEccen = eccen <= sampleEccen(eccenInd);
        %if thisEccen == 1
            %stimdrivenRFs(3,pRFInd) = sigma(eccenInd);
            %break
        %end
    %end
end

%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;

%% Stimulus and Suppressive Drive
stimdrive = zeros(size(stimdrivenRFs,2),size(inputStim,3));
numerator = zeros(size(stimdrivenRFs,2),size(inputStim,3));

for rfind = 1:size(stimdrivenRFs,2)
    for ii = 1:size(inputStim,3)
        % get the stim driven RF 
        RF = exp(-((X-(stimdrivenRFs(1,rfind))).^2 + ...
            (Y-(stimdrivenRFs(2,rfind))).^2)./(2*(stimdrivenRFs(3,rfind))).^2);
         RF = RF./sum(RF(:));
        % impose the attention field
        RFattn = RF .* attfield;
        % get the stimulus vectorized
        stim = inputStim(:,:,ii);
        stim = stim(:);
        stimdrive(rfind, ii) = RF(:)'*stim;
        numerator(rfind, ii) = RFattn(:)'*stim;
    end
end
stimdrive_pop = zeros(size(inputStim,1),size(inputStim,2),size(inputStim,3));
numerator_pop = zeros(size(inputStim,1),size(inputStim,2),size(inputStim,3));

for s = 1:size(stimdrive,2)
    stimdrive_pop(:,:,s) = reshape(stimdrive(:,s), [size(inputStim,1) size(inputStim,2)]);
    numerator_pop(:,:,s) = reshape(numerator(:,s), [size(inputStim,1) size(inputStim,2)]);
end
% 
% close all
% figure
% for s = 1:size(stimdrive,2)
%     imagesc(stimdrive_pop(:,:,s))
%     pause(1)
% end
% 
% close all
% figure
% for s = 1:size(stimdrive,2)
%     imagesc(numerator_pop(:,:,s))
%     pause(1)
% end
% 

% close all
% iter =1;
% figure;
% for ind = 1:500:size(stimdrive,1)
%     subplot(4,5,iter)
%     plot(stimdrive(ind,:))
%     hold on
%     plot(numerator(ind,:))
%     if iter == 1
%         legend('with attention', 'without attention')
%     end
%     iter = iter +1;
% end


%% old part
% stimdrive = convn(inputStim, RF, 'same');
% stimdrive = inputStim.*RF;
% numerator = stimdrive .* (attfield);
suppdrive = convn(numerator_pop, RFsupp, 'same');

%% population response
sptPopResp = numerator_pop ./ (suppdrive + sigmaNorm);
close all, for ii = 1:size(sptPopResp,3), imagesc(sptPopResp(:,:,ii)), pause(0.5), end

pooledPopResp = convn(sptPopResp, RFsumm, 'same');
% Go across time for a specific location in the pop response,let's say x =
% 1, y = 2. 
predneuralweights = reshape(sptPopResp,[size(sptPopResp,1)*size(sptPopResp,2) size(sptPopResp,3)]);
predsummedweights = reshape(pooledPopResp,[size(pooledPopResp,1)*size(pooledPopResp,2) size(pooledPopResp,3)]);

end