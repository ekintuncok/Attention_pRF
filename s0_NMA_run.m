addpath(genpath(aprfRootPath))
maindir     = '/Volumes/server/Projects/attentionpRF/Simulations/';

mxecc       = 10;
summationsd = 2;
sigma       = 0.1;
visualize   = 1;
attx0       = 2;
atty0       = 0;
RFsd        = 1;
attsd       = 1.5;
attgain     = 2;
params      = [mxecc,RFsd,attgain,attx0,atty0,attsd,summationsd,sigma];

[X, Y, sptPopResp, pooledPopResp, predTimeSeries] = NMA_simulate2D(maindir, params);