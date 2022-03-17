%maindir     = '/Volumes/server/Projects/attentionpRF/Simulations/';
%addpath(genpath(maindir))
maindir = './';

mxecc       = 10;
sigma       = 0.1;
attx0locs   = [-2, 1, 0, 6];
atty0locs   = [0, 2, 5, -3];
attsd       = 1.5;
attgain     = 2.5;
visualize   = 0;

params      = [mxecc,0,0,0,attsd,sigma,visualize];
[stimdrive_base, numeratorIm_base, suppIm_base, baselineSpatialResponse, baselinepredneuralweights] ...
    = NMA_simulate2D(maindir, params);

for cond = 1:length(attx0locs)
    params      = [mxecc,attgain,attx0locs(cond),atty0locs(cond),attsd,sigma,visualize];
    [stimdriveIm(:,:,:,cond), numeratorIm(:,:,:,cond), suppIm(:,:,:,cond), sptPopResp(:,:,:,cond), predneuralweights(:,:,cond)] ...
        = NMA_simulate2D(maindir, params);
end

cmap = [255,245,240; 254,224,210; 252,187,161;...
    252,146,114; 251,106,74; 239,59,44; ...
    203,24,29; 165,15,21;103,0,13]/255;

for condind = 1:length(attx0locs)
    figure
    subplot(2,2,1)
    imagesc(sum(stimdriveIm(:,:,:,condind),3))
    title('Stimulus drive')
    colormap(cmap)
    colorbar
    subplot(2,2,2)
    imagesc(sum(numeratorIm(:,:,:,condind),3))
    title('Numerator (stimulus drive.*attfield)')
    colormap(cmap)
    colorbar
    subplot(2,2,3)
    imagesc(sum(suppIm(:,:,:,condind),3))
    title('Suppressive drive')
    colormap(cmap)
    colorbar
    subplot(2,2,4)
    imagesc(sum(sptPopResp(:,:,:,condind),3))
    title('Population response')
    colormap(cmap)
    colorbar
end

for condind = 3
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