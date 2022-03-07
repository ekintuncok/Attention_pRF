maindir     = '/Volumes/server/Projects/attentionpRF/Simulations/';
addpath(genpath(maindir))

mxecc       = 10;
summationsd = 2;
sigma       = 0.1;
visualize   = 1;
attx0locs   = [-5, 5];
atty0       = 0;
RFsd        = 1;
attsd       = 1.5;
attgain     = 2;

params      = [mxecc,RFsd,0,0,atty0,attsd,summationsd,sigma];
[X, Y,~ , ~, ~, baselineresponse] = NMA_simulate2D(maindir, params);

for cond = 1:length(attx0locs)
    params      = [mxecc,RFsd,attgain,attx0locs(cond),atty0,attsd,summationsd,sigma];
    [X, Y, stim, sptPopResp(:,:,:,cond), pooledPopResp(:,:,:,cond), predTimeSeries(:,:,cond)] = NMA_simulate2D(maindir, params);
end

iter = 1;
figure;
neurons =floor(linspace(1,length(predTimeSeries), 50));
for ind = neurons
    subplot(5,10,iter)
    plot(predTimeSeries(ind,:,1))
    hold on
    plot(predTimeSeries(ind,:,2))
    hold on 
    plot(baselineresponse(ind,:))
    if iter == 1
        legend('attend left','attend right','sensory RF')
    end
    iter = iter+1;
end

figure
subplot(2,2,1)
plot(predTimeSeries(:,12,1))
hold on
plot(predTimeSeries(:,12,2))
hold on 
plot(baselineresponse(:,12))
legend('attend left','attend right','sensory RF')
subplot(2,2,2)
plot(predTimeSeries(:,30,1))
hold on
plot(predTimeSeries(:,30,2))
hold on 
plot(baselineresponse(:,30))
subplot(2,2,3)
imagesc(stim(:,:,12))
subplot(2,2,4)
imagesc(stim(:,:,30))



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
plot((baselineresponse-predTimeSeries(:,:,1))')
subplot(1,2,2)
plot((baselineresponse-predTimeSeries(:,:,2))')
