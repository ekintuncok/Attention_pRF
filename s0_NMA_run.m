%maindir     = '/Volumes/server/Projects/attentionpRF/Simulations/';
%addpath(genpath(maindir))
maindir = './';

mxecc       = 10;
sigma       = 0.1;
attx0locs   = [0, 0, -5, 5];
atty0locs   = [5, -5, 0, 0];
attsd       = 1.5;
attgain     = [2, 4, 4, 4];
visualize   = 0;

params      = [mxecc,0,0,1,3,sigma,visualize];
[stimdrive_base, numeratorIm_base, suppIm_base, baselineSpatialResponse, baselinepredneuralweights] ...
    = NMA_simulate2D(maindir, params);

% save the simulated data:
datatofit = cat(3, predneuralweights, baselinepredneuralweights);
save('/Volumes/server/Projects/attentionpRF/Simulations/fitData/simulateddata.mat', 'datatofit');
for cond = 1:length(attx0locs)
    params      = [mxecc,attgain(cond),attx0locs(cond),atty0locs(cond),attsd,sigma,visualize];
    [stimdriveIm(:,:,:,cond), numeratorIm(:,:,:,cond), suppIm(:,:,:,cond), sptPopResp(:,:,:,cond), predneuralweights(:,:,cond)] ...
        = NMA_simulate2D(maindir, params);
end

cmap = [255,245,240; 254,224,210; 252,187,161;...
    252,146,114; 251,106,74; 239,59,44; ...
    203,24,29; 165,15,21;103,0,13]/255;

% Plot the predicted population responses for cued conditions:

for condind = 1:length(attx0locs)
    figure
    subplot(1,3,1)
    imagesc(sum(numeratorIm(:,:,:,condind),3))
    title('Numerator (stimulus drive.*attfield)')
    colormap(cmap)
    colorbar
    subplot(1,3,2)
    imagesc(sum(suppIm(:,:,:,condind),3))
    title('Suppressive drive')
    colormap(cmap)
    colorbar
    subplot(1,3,3)
    imagesc(sum(sptPopResp(:,:,:,condind),3))
    title('Population response')
    colormap(cmap)
    colorbar
    set(gcf, 'Position', [0 0 900 175])
end

% Plot the predicted population responses for the baseline/neutral cue condition:
figure
subplot(1,3,1)
imagesc(sum(numeratorIm_base,3))
title('Numerator (stimulus drive.*attfield)')
colormap(cmap)
colorbar
subplot(1,3,2)
imagesc(sum(suppIm_base,3))
title('Suppressive drive')
colormap(cmap)
colorbar
subplot(1,3,3)
imagesc(sum(baselineSpatialResponse,3))
title('Population response')
colormap(cmap)
colorbar
set(gcf, 'Position', [0 0 900 175])



for condind = 1:length(attx0locs)
    figure
    subplot(2,2,1)
    imagesc(stimdriveIm(:,:,32,condind))
    title('Stimulus drive')
    colormap(cmap)
    axis off 
    subplot(2,2,2)
    imagesc(numeratorIm(:,:,32,condind))
    title('Numerator (stimulus drive.*attfield)')
    colormap(cmap)
    axis off   
    subplot(2,2,3)
    imagesc(suppIm(:,:,32,condind))
    title('Suppressive drive')
    colormap(cmap)
    axis off
    subplot(2,2,4)
    imagesc(sptPopResp(:,:,32,condind))
    title('Population response')
    colormap(cmap)
    axis off
end


% cmap = [254,240,217;
% 253,212,158;
% 253,187,132;
% 252,141,89;
% 227,74,51;
% 179,0,0]/255;