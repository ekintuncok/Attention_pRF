function [stimdriveIm, numeratorIm, suppIm, sptPopResp, predneuralweights, predsummedweights] = NMA_simulate2D(maindir, params)

stim_ecc    = params(1);
attgain     = params(2);
attx0       = params(3);
atty0       = params(4);
attsd       = params(5);
sigmaNorm   = params(6);
spacegrid   = params(7);


%% Create and scale stimuli
stimtemp = load([fullfile(maindir, 'stimfiles/') 'stim.mat']);
stim    = stimtemp.stim(:,:,1:end-1);
stim    = logical(stim);

[inputStim, X, Y] = createSpatialGrid(stim, stim_ecc, spacegrid);
flatten     = @(x) reshape(x, spacegrid*spacegrid, []);
unflatten   = @(x) reshape(x, spacegrid, spacegrid, []);

%% Simulate RFs
nCenters      = size(inputStim,1);
x             = -1*linspace(-8.8,8.8,nCenters);
y             = linspace(-8.8,8.8,nCenters);
nPRFs         = size(CombVec(y,x),2);
stimdrivenRFs = CombVec(x,y);

% If we keep the x- and y- axes range (look a line up) at [-10 to 10] our
% max eccentricity goes up to 14 degrees. Now we need to assign our sigma
% value accordingly.

for pRFInd = 1:nPRFs
    currCenter = stimdrivenRFs(1:2,pRFInd);
    eccen = sqrt(currCenter(1).^2 + currCenter(2).^2);
    stimdrivenRFs(3,pRFInd) = 0.05 + 0.1*eccen;
end

%% Attention field
attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;
attfield = flatten(attfield);

%% Stimulus and Suppressive Drive
stimdrive    = zeros(size(stimdrivenRFs,2),size(inputStim,3));
numeratorVec = zeros(size(stimdrivenRFs,2),size(inputStim,3));
respSurround = zeros(size(stimdrivenRFs,2),size(inputStim,3));

for ii = 1:size(inputStim,3)
    for rfind = 1:size(stimdrivenRFs,2)
        % get the stim driven RF
        RF = exp(-((X-(stimdrivenRFs(2,rfind))).^2 + ...
            (Y-(stimdrivenRFs(1,rfind))).^2)./(2*(stimdrivenRFs(3,rfind))).^2);
        RF = RF./sum(RF(:));
        RF = flatten(RF);
        % get the stimulus vectorized
        stim = inputStim(:,:,ii);
        stim = flatten(stim);
        stimdrive(rfind, ii) = RF'*stim;    
    end
    numeratorVec(:,ii) = stimdrive(:,ii).*attfield;
    for rfind = 1:size(stimdrivenRFs,2)
        distance = sqrt((X-stimdrivenRFs(2,rfind)).^2+(Y-stimdrivenRFs(1,rfind)).^2);
        % find the weights for the surround
        supp = exp(-.5*(distance/(stimdrivenRFs(3,rfind)*3)).^2);
        supp = supp / sum(supp(:));
        flatsurr = flatten(supp);
        respSurround(rfind,ii) = flatsurr' * numeratorVec(:,ii);
    end
end

stimdriveIm = unflatten(stimdrive);
numeratorIm = unflatten(numeratorVec);
suppIm      = unflatten(respSurround);

%% population response
sptPopResp = numeratorIm ./ (suppIm + sigmaNorm);
predneuralweights = flatten(sptPopResp);
predsummedweights = zeros(size(stimdrivenRFs,2),size(inputStim,3));

for ii = 1:size(predneuralweights,2)
    for rfind = 1:size(stimdrivenRFs,2)
        distance = sqrt((X-stimdrivenRFs(2,rfind)).^2+(Y-stimdrivenRFs(1,rfind)).^2);
        summation = exp(-.5*(distance/(stimdrivenRFs(3,rfind)*4)).^2);
        summation = summation / sum(summation(:));
        flatsumm = flatten(summation);
        predsummedweights(rfind,ii) = flatsumm' * predneuralweights(:,ii);
    end
end
end
