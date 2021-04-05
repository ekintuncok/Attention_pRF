addpath('/Users/et2160/Desktop/Attention_pRF-main');
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
t = 1:timepoints;

% Define a hemodynamic impulse response function
h = t .* exp(-t/5);
h = h / sum(h); % normalize to sum of 1

% Define the stimulus driven RF parameters
x = linspace(-10,10,10); y = linspace(-10,10,10); sigma = linspace(1,5,10); % in degrees of visual field
% Define the attention field parameters
AF_x = 12; AF_y = 0; AF_sigma = 2;

% Create pink noise
% whitenoise = randn(1,300);
% noise = cumsum(whitenoise);
% minNoise = min(noise); %not sure how else to fix the scaling problem here. In the following line as well.

% Simulate (one tiny) dataset:
[~,AFSimVec] = createGauissanFields(X,Y,AF_x,AF_y,AF_sigma);

for ii = 1:length(x)
[~,RFSimVec] = createGauissanFields(X,Y,x(ii),y(ii),sigma(ii));
boldMeasured1(ii,:) = conv(AFSimVec .* RFSimVec * stimVec,h);
boldMeasured(ii,:) = mx(boldMeasured1(ii,1:timepoints)) + pinknoise(300)';
end

data=boldMeasured;

%% FITS
%Harvey & Dumoulin -- multiplication of two Gaussians. 
%Attention effects on pRF size: 
%Estimate 3 parameters: 
% 1) stim driven pRF position [x], [y];
% 2) stim driven pRF size [sigma]
% 3) attention field size [AF_sigma]
x0 = [0 , 0, 1]; % Define the initial values
% A = [1,0,0;0,1,0]; % Up to 10deg visual field eccentricity & polar angle:
% b = [10;10];
lb = [-10, -10, 0]; % Lower bound
ub = [10, 10, 5]; % Lower bound

for ii = 1:length(x)
fun = @(p) (RSSR(p,stim,data(ii,:)));
fitParams(ii,:) = fmincon(fun,x0,[],[],[],[],lb,ub);
end
