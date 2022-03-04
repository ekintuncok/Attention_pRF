addpath(genpath(aprfRootPath))

npoints     = 1001;
mxecc       = 10;
summationsd = 2;
sigma       = 0.1;
visualize   = 1;
attx0       = 2;
atty0       = 0;
RFsd        = 1;
attsd       = 1.5;
attgain     = 2;
params      = [ones, npoints,mxecc,RFsd,attgain,attx0,atty0,attsd,summationsd,sigma,1];

[X, Y, popresp, summation] = NMA_simulate2D(params);