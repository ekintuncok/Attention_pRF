%% make little stim images for the manuscript:
load('/Users/et2160/Desktop/ExperimentScripts/attention_pRF/output.mat');
load('/Users/et2160/Desktop/ExperimentScripts/attention_pRF/verticalMappingMask.mat');
load('/Users/et2160/Desktop/new_fig.mat');

bandpass_ptrn = h1;
%bandpass_ptrn = repmat([127]/255, size(output{1}));
mask = verticalMappingMask(:,:,6);
%mask = ones(size(verticalMappingMask(:,:,1)));
img = bandpass_ptrn .* mask;

display_center = size(bandpass_ptrn,1)/2;

% draw fixation:
height = 100;
width = 10;
img(display_center:display_center+20, display_center:display_center+height) = 1;
img(display_center:display_center+20, display_center-height:display_center) = 1;

img(display_center-height:display_center, display_center-width:display_center+width) = 1;
img(display_center:display_center+height+5, display_center-width:display_center+width) = -1;


figure;imshow(img,[])
set(gcf,'Position',[0 0 800 800])


halfSize = 100;
gaussEnv = 60;
spatialFreq = 0.012;
angle = 25;
[xx,yy] = meshgrid(-halfSize:halfSize, -halfSize:halfSize);
sinePart = sin(2*pi*spatialFreq * (xx*cosd(angle) + yy*sind(angle)));
gaussianPart = exp(-((xx/gaussEnv).^2 + (yy/gaussEnv).^2));
patch = gaussianPart.*sinePart;

circ_mask = sum(verticalMappingMask,3);
circ_mask = imresize(circ_mask, [size(patch,1), size(patch,2)]);
% imshow(sinePart.* circ_mask,[])
% figure;imshow(img)
% set(gcf,'Position',[1000 500 800 800])
