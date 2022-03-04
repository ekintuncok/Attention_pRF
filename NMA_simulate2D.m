function [X, Y, popresp, summation] = NMA_simulate2D(params)

npoints     = params(2);
mxecc       = params(3);
RFsd        = params(4);
attgain     = params(5);
attx0       = params(6);
atty0       = params(7);
attsd       = params(8);
summationsd = params(9);
sigma       = params(10);
visualize   = params(11);

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
stim(:,100:230) = 1;
stim = stim(1:npoints,1:npoints);
%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;
%% Stimulus and Suppressive Drive
stimdrive = conv2(stim, RF, 'same');
numerator = stimdrive .* (attfield);
suppdrive = conv2(numerator, RFsupp, 'same');

%% population response
popresp = numerator ./ (suppdrive + sigma);
summation = conv2(popresp, RFsumm, 'same');
if visualize
    fH = figure; clf;
    lw = 3;
    fs = 10;
    subplot(2,3,1);
    imagesc(RF);
    title('RF, center and surround');
    plotOptions(gca, fs);
    subplot(2,3,2); 
    imagesc(attfield);
    title('Attention field');
    plotOptions(gca, fs);
    subplot(2,3,3);
    imagesc(x, x, stim')
    title('Stimuli');
    plotOptions(gca, fs);
    subplot(2,3,4);
    imagesc(x, x, stimdrive);
    title('Stimulus drive');
    plotOptions(gca, fs);
    ylabel('Neural population')
    xlabel('Stimulus')
    subplot(2,3,5);
    imagesc(x, x, suppdrive);
    title('Suppressive drive');
    plotOptions(gca, fs);
    ylabel('Neural population')
    xlabel('Stimulus')
    subplot(2,3,6);
    imagesc(x, x, popresp);
    title('Population response');
    plotOptions(gca, fs);
    ylabel('Neural population')
    xlabel('Stimulus')
    set(gcf,'Position',[0 0 600 350])
end
end