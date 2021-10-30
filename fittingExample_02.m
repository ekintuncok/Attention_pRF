
mx = @(x) x / max(x(:)); %Because of the small values obtained when AF and RF are multiplied
% Read in some stimulus apertures
load('RETBARsmall.mat', 'stim');
stim    = logical(stim);
rows    = size(stim,1);
cols    = size(stim,2);
timepoints = size(stim,3);
% Compute the time course
stimVec   = reshape(stim, rows*cols, timepoints);
% Define the visual field positions and time
[X,Y] = meshgrid(linspace(-10,10,cols), linspace(-10,10, rows));
t = (1:timepoints)'; % column vector of time points

% Define a hemodynamic impulse response function
h = t .* exp(-t/5);
h = h / sum(h); % normalize to sum of 1

% Define the stimulus driven RF parameters
nPRFs   = 50;
x       = linspace(-10,10,nPRFs); 
y       = linspace(-10,10,nPRFs); 
sigma   = linspace(1,5,nPRFs); % in degrees of visual field

% Define the attention field parameters
% AF parameters here are set for Gabor targets (AFs) that are positioned
% along the horizontal meridian. Therefore, Y is always equal to 0. 
nAFs   = 20;
AF_x    = linspace(-10,10,nAFs); 
AF_y    = 0; 
AF_sigma = 1;
% AF_x = 12; AF_y = 0; AF_sigma = 2; %adjusted the AF coordinates so that it falls outside of the mapped eccentricity

% Simulate (one tiny) dataset with pink noise added:
noiselessBOLD  = cell(nAFs,1);data  = cell(nAFs,1);

for jj = 1:nAFs
    for ii = 1:nPRFs
        [~,RFSimVec] = createGauissanFields(X,Y,x(ii),y(ii),sigma(ii));
        [~,AFSimVec] = createGauissanFields(X,Y,AF_x(jj),AF_y,AF_sigma);
        tmp = conv(AFSimVec .* RFSimVec * stimVec,h);
        tmp = tmp / std(tmp);
        noiselessBOLD{jj}(:,ii) = tmp(1:timepoints);
        whitenoise = randn(timepoints, 1);
        pinknoise  = zscore(cumsum(whitenoise));
        data{jj}(:,ii) = noiselessBOLD{jj}(:,ii) + pinknoise;
    end
end


%% FITS
%Harvey & Dumoulin -- multiplication of two Gaussians. 
%Attention effects on pRF size: 
%Estimate 3 parameters: 
% 1) stim driven pRF position [x], [y];
% 2) stim driven pRF size [sigma]
% 3) attention field size [AF_sigma]
x0 = [0 , 0, 1]; % Define the initial values
% A = [1,0,0;0,1,0];
% b = [10;10];
lb = [-10, -10,  0.01]; % Lower bound
ub = [ 10,  10, 10];    % Lower bound

fitParams= cell(nAFs,1);

for jj = 1:nAFs
    for ii = 1:nPRFs
        fprintf('Solving pRF for voxel %d of attention field %d\n', ii, jj);
        fun = @(p) (RSSR(p,stim,data{jj}(:,ii)));
        fitParams{jj}(:,ii) = fmincon(fun,x0,[],[],[],[],lb,ub);
    end
end

% True params
stimParams = [x;y;sigma];
attParamsRight = [AF_x; repmat(AF_y,1,20); repmat(AF_sigma,1,20)];
attParamsLeft = [-AF_x; repmat(AF_y,1,20); repmat(AF_sigma,1,20)];

for ii = 1:nAFs
appPRFparamsR{ii} = stim2app(stimParams, attParamsRight(:,ii));
appPRFparamsL{ii} = stim2app(stimParams, attParamsLeft(:,ii));
end 
 %% Plot the pRF fits and model prediction
 % Find a better way to index each subplot (npRFs might and will change)
for ii = 1:length(attParamsRight)
    if (1 <= ii) &&  (ii <= 5)
figure(1);
subplot(5, 3, 2*ii+ii-2)
scatter(fitParams{ii}(1,:),appPRFparamsR{ii}(1,:))
xlabel('pRF fit X Coord')
ylabel('AF Model prediction X Coord')
title(num2str(attParamsRight(1,ii)))
subplot(5, 3, 2*ii+ii-1)
scatter(fitParams{ii}(2,:),appPRFparamsR{ii}(2,:))
xlabel('pRF fit Y Coord')
ylabel('AF Model prediction Y Coord')
title(num2str(attParamsRight(2,ii)))
subplot(5, 3, 3*ii)
scatter(fitParams{ii}(3,:),appPRFparamsR{ii}(3,:))
xlabel('pRF fit Sigma')
ylabel('AF Model prediction Sigma')
title(num2str(attParamsRight(3,ii)))
hold on
    end
    if (6 <= ii) &&  (ii <= 10)
        jj = ii-5;
figure(2);
subplot(5, 3, 2*jj+jj-2)
scatter(fitParams{ii}(1,:),appPRFparamsR{ii}(1,:))
xlabel('pRF fit X Coord')
ylabel('AF Model prediction X Coord')
title(num2str(attParamsRight(1,ii)))
subplot(5, 3, 2*jj+jj-1)
scatter(fitParams{ii}(2,:),appPRFparamsR{ii}(2,:))
xlabel('pRF fit Y Coord')
ylabel('AF Model prediction Y Coord')
title(num2str(attParamsRight(2,ii)))
subplot(5, 3, 3*jj)
scatter(fitParams{ii}(3,:),appPRFparamsR{ii}(3,:))
xlabel('pRF fit Sigma')
ylabel('AF Model prediction Sigma')
title(num2str(attParamsRight(3,ii)))
hold on
    end
    if (11 <= ii) && (ii <= 15)
        jj = ii-10;
figure(3);
subplot(5, 3, 2*jj+jj-2)
scatter(fitParams{ii}(1,:),appPRFparamsR{ii}(1,:))
xlabel('pRF fit X Coord')
ylabel('AF Model prediction X Coord')
title(num2str(attParamsRight(1,ii)))
subplot(5, 3, 2*jj+jj-1)
scatter(fitParams{ii}(2,:),appPRFparamsR{ii}(2,:))
xlabel('pRF fit Y Coord')
ylabel('AF Model prediction Y Coord')
title(num2str(attParamsRight(2,ii)))
subplot(5, 3, 3*jj)
scatter(fitParams{ii}(3,:),appPRFparamsR{ii}(3,:))
xlabel('pRF fit Sigma')
ylabel('AF Model prediction Sigma')
title(num2str(attParamsRight(3,ii)))
    end
    if (16 <= ii) &&  (ii <= 20)
        jj = ii-15;
figure(4);
subplot(5, 3, 2*jj+jj-2)
scatter(fitParams{ii}(1,:),appPRFparamsR{ii}(1,:))
xlabel('pRF fit X Coord')
ylabel('AF Model prediction X Coord')
title(num2str(attParamsRight(1,ii)))
subplot(5, 3, 2*jj+jj-1)
scatter(fitParams{ii}(2,:),appPRFparamsR{ii}(2,:))
xlabel('pRF fit Y Coord')
ylabel('AF Model prediction Y Coord')
title(num2str(attParamsRight(2,ii)))
subplot(5, 3, 3*jj)
scatter(fitParams{ii}(3,:),appPRFparamsR{ii}(3,:))
xlabel('pRF fit Sigma')
ylabel('AF Model prediction Sigma')
title(num2str(attParamsRight(3,ii)))
    end
end
%% PLOTS
% % See how the apparent pRFs change for different stimulus driven pRFs when
% % attenional field is kept constant:
% 
% apparentpRFs = cell(1,length(x));
% stimpRFs = cell(1,length(x));
% for ii = 1:length(x)
% [apparentpRFs{ii},~] = createGauissanFields(X,Y,fitParams(1,ii),fitParams(2,ii),fitParams(3,ii));
% [stimpRFs{ii},~] = createGauissanFields(X,Y,appPRFparamsR(ii),appPRFparamsR(ii),AF_sigma);
% end
% 
% for ii = 1:20
%     figure (1);
% subplot(10,2,2*ii-1)
% imagesc(X(:), Y(:), stimpRFs{ii}); axis image xy; 
% title('Stim-driven pRF')
% subplot(10,2,2*ii)
% imagesc(X(:), Y(:), apparentpRFs{ii}); axis image xy; 
% title('Apparent pRF (Stim-driven pRF * Attentional field)')
% end
% set(gcf, 'Position',[0, 1000,1000,1000])
