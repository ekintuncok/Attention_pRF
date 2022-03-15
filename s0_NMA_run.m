%maindir     = '/Volumes/server/Projects/attentionpRF/Simulations/';
%addpath(genpath(maindir))
maindir = './';

mxecc       = 10;
sigma       = 0.1;
attx0locs   = [-5, 5, 0 , 0];
atty0locs   = [0, 0, 5, -5];
attsd       = 1.5;
attgain     = 20;
visualize   = 0;
params      = [mxecc,0,0,atty0,attsd,sigma,visualize];
[stimdrive_base, numeratorIm_base, suppIm_base, baselineSpatialResponse, baselinepredneuralweights] ...
    = NMA_simulate2D(maindir, params);

for cond = 1:length(attx0locs)
     params      = [mxecc,attgain,attx0locs(cond),atty0locs(cond),attsd,sigma,visualize];
    [stimdriveIm(:,:,:,cond), numeratorIm(:,:,:,cond), suppIm(:,:,:,cond), sptPopResp(:,:,:,cond), predneuralweights(:,:,cond)] ...
        = NMA_simulate2D(maindir, params);
end

for condind = 1:length(attx0locs)
    figure(condind)
    subplot(2,2,1)
    imagesc(sum(stimdriveIm(:,:,:,condind),3))
    title('Stimulus drive')
    colormap hot
    colorbar
    subplot(2,2,2)
    imagesc(sum(numeratorIm(:,:,:,condind),3))
    title('Numerator (stimulus drive.*attfield)')
    colormap hot
    colorbar
    subplot(2,2,3)
    imagesc(sum(suppIm(:,:,:,condind),3))
    title('Suppressive drive')
    colormap hot
    colorbar
    subplot(2,2,4)
    imagesc(sum(sptPopResp(:,:,:,condind),3))
    title('Population response')
    colormap hot
    colorbar
end


iter = 1;
figure;
voxels =floor(linspace(1,length(predneuralweights), 50));
for ind = voxels
    subplot(5,10,iter)
    plot(predneuralweights(ind,:,1))
    hold on
    plot(predneuralweights(ind,:,2))
    hold on 
    plot(baselinepredneuralweights(ind,:))
    if iter == 1
        legend('attend left','attend right','sensory RF')
    end
    iter = iter+1;
end

figure
subplot(2,2,1)
plot(predneuralweights(:,12,1))
hold on
plot(predneuralweights(:,12,2))
hold on 
plot(baselinepredneuralweights(:,12))
legend('attend left','attend right','sensory RF')
subplot(2,2,2)
plot(predneuralweights(:,30,1))
hold on
plot(predneuralweights(:,30,2))
hold on 
plot(baselinepredneuralweights(:,30))


figure;
subplot(2,2,1)
imagesc(sptPopResp(:,:,10,1))
subplot(2,2,2)
imagesc(sptPopResp(:,:,10,2))
subplot(2,2,3)
imagesc(sptPopResp(:,:,32,1))
subplot(2,2,4)
imagesc(sptPopResp(:,:,32,2))
% 
% 
figure;
subplot(1,2,1)
plot((baselinepredneuralweights-predneuralweights(:,:,1))')
subplot(1,2,2)
plot((baselinepredneuralweights-predneuralweights(:,:,2))')

subplot(1,2,1)
plot((predneuralweights(:,:,1)-baselinepredneuralweights)')
title('Macro norm - attend left');
subplot(1,2,2)
plot((predneuralweights(:,:,2)-baselinepredneuralweights)')
title('Macro norm - attend right');

