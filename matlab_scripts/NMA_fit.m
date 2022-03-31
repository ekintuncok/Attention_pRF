function estimatedParameters = NMA_fit(datatofit, stim, stim_ecc, attentionLocations)

baselineactivity = datatofit(:,:,5);
% fit pRFs to the neutral condition:
stimdrivenRFs = getSensoryDrivenpRF(baselineactivity, stim);
fittedrfs = stimdrivenRFs;
save('/Volumes/server/Project/attentionpRF/Simulations/fittedrfs_wholeset.mat', 'fittedrfs');
fprintf('>>>Sensory driven pRFs estimated...');

attentiondata = datatofit(:,:,1:4); attentionLocations = attentionLocations(1:4,:);
estimatedParameters = fitMain(attentiondata, stimdrivenRFs,stim, stim_ecc, attentionLocations);

end
