function [X, Y, stim, sptPopResp, pooledPopResp, predTimeSeries] = NMA_simulate2D(maindir, params)

mxecc       = params(1);
RFsd        = params(2);
attgain     = params(3);
attx0       = params(4);
atty0       = params(5);
attsd       = params(6);
pooledPopRespsd = params(7);
sigma       = params(8);

%% Space (1D)
step_size = mxecc/50;
[X,Y] = meshgrid(-mxecc:step_size:mxecc);

%% Neural RFs
RF = exp(-((X-0).^2 +(Y-0).^2)./(2*RFsd).^2);
RFsupp = exp(- ((X-0).^2 + (Y-0).^2)./(2*1.5*RFsd).^2);
%% Voxel pooledPopResp (across neurons)
RFsumm = exp(-((X-0).^2 +(Y-0).^2)./(2*pooledPopRespsd).^2);
%% Stimuli
load([fullfile(maindir, 'stimfiles/') 'stim.mat'])
stim    = stim(:,:,1:end-1);
stim    = logical(stim);

inputStim = zeros(size(X,1),size(X,1),size(stim,3));
for s = 1:size(stim,3)
    inputStim(:,:,s) = imresize(stim(:,:,s),[size(X,1) size(X,1)],'nearest');
end
close all, for ii = 1:size(inputStim,3), imagesc(inputStim(:,:,ii)), pause(0.5), end
%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;

%% Stimulus and Suppressive Drive
stimdrive = convn(inputStim, RF, 'same');
% stimdrive = inputStim.*RF;
numerator = stimdrive .* (attfield);
suppdrive = convn(numerator, RFsupp, 'same');

%% population response
sptPopResp = numerator ./ (suppdrive + sigma);
pooledPopResp = convn(sptPopResp, RFsumm, 'same');
% close all;for s = 1 : size(pooledPopResp,3); imagesc(pooledPopResp(:,:,s)); pause(1); end
% Go across time for a specific location in the pop response,let's say x =
% 1, y = 2. 
predTimeSeries = reshape(pooledPopResp,[size(pooledPopResp,1)*size(pooledPopResp,2) size(pooledPopResp,3)]);

end