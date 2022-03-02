function [X, Y, popresp, summation] = NMA_simulate2D(params)

npoints     = params(2);
mxecc       = params(3);
RFsd        = params(4);
attgain     = params(5);
attx0       = params(6);
attsd       = params(7);
summationsd = params(8);
sigma       = params(9);
visualize   = params(10);

%% Space (1D)
[X,Y] = meshgrid(linspace(-mxecc,mxecc,npoints), linspace(-mxecc,mxecc, npoints));
%% Neural RFs
RF = exp(-((X-0).^2 +(Y-0).^2)./(2*RFsd).^2);
%RF = RF / sum(RF);
RFsupp = exp(- ((X-0).^2 + (Y-0).^2)./(2*3*RFsd).^2);
%RFsupp = RFsupp / sum(RFsupp);
%% Voxel summation (across neurons)
RFsumm = exp(-((X-0).^2 +(Y-0).^2)./(2*summationsd).^2);
%% Stimuli
stim = zeros(npoints,npoints);
stim(:,450:500) = 1;
%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-attx0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;
%% Stimulus and Suppressive Drive
stimdrive = conv2(stim, RF, 'same');
numerator = stimdrive .* (attfield);
suppdrive = conv2(numerator, RFsupp, 'same');

%% population response
popresp = numerator ./ (suppdrive + sigma);
summation = conv2(popresp, RFsumm, 'same');
x = linspace(-mxecc,mxecc, npoints);
if visualize
    fH = figure; clf;
    lw = 3;
    fs = 10;
    subplot(2,4,1);
    imagesc(x,x,RF);
    title('RF center');
    plotOptions(gca, fs);
    subplot(2,4,2);
    imagesc(x,x,attfield);
    title('Attention field');
    plotOptions(gca, fs);
    subplot(2,4,3);
    imagesc(x,x,stim)
    title('Stimuli');
    plotOptions(gca, fs);
    subplot(2,4,4);
    imagesc(x, x, stimdrive);
    title('Stimulus drive');
    plotOptions(gca, fs);
    subplot(2,4,5);
    imagesc(x, x, numerator);
    title('Stimulus drive under the attention field');
    plotOptions(gca, fs);
    subplot(2,4,6);
    imagesc(x, x, suppdrive);
    title('Suppressive drive');
    plotOptions(gca, fs);
    subplot(2,4,7);
    imagesc(x, x, popresp);
    title('Population response');
    plotOptions(gca, fs);
    subplot(2,4,8);
    imagesc(x, x, popresp);
    title('Population response');
    plotOptions(gca, fs);
    set(gcf,'Position',[0 0 1100 450])
end
end