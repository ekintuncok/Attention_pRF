clear all
maindir = '/Volumes/server/Projects/attentionpRF/Simulations';
addpath(genpath(maindir));
% load the stim
load('/Volumes/server/Projects/attentionpRF/Simulations/stimfiles/stim.mat', 'stim')
stim = stim(:,:,1:end-1);
% load the data
load('/Volumes/server/Projects/attentionpRF/Simulations/fitData/simulateddata.mat', 'datatofit')

% define the max eccentricity
stim_ecc = 12;

attentionLocations = [1, 0, 5;
    2, 0, -5;
    3, -5, 0;
    4, 5, 0;
    5, 0, 0];

estimatedParameters = NMA_fit(datatofit, stim, stim_ecc, attentionLocations);