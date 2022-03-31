function predneuralweights = normalizationmodel(stim, stim_ecc, stimdrivenRFs, attx0, atty0, attsd, attgain, sigmaNorm)
% % pad stimulus with zeros to avoid edge artifacts
spacegrid = sqrt(length(stimdrivenRFs));
ecc = linspace(-stim_ecc,stim_ecc,spacegrid);
[X,Y] = meshgrid(ecc);
Y = -1*Y;
inputStim = zeros(size(X,1),size(X,1),size(stim,3));
fullSize = size(X,1);
stimSize = fullSize-(0.25*fullSize);
imStart = fullSize/2-(stimSize/2);
imEnd = imStart+stimSize-1;
imIdx = imStart:imEnd;
for s = 1:size(stim,3)
    inputStim(imIdx,imIdx,s) = imresize(stim(:,:,s),[stimSize stimSize],'nearest');
end

flatten     = @(x) reshape(x, spacegrid*spacegrid, []);
unflatten   = @(x) reshape(x, spacegrid, spacegrid, []);

attfield = exp(-((X-attx0).^2 +(Y-atty0).^2)./(2*attsd).^2);
attfield = attgain*attfield  + 1;
attfield = flatten(attfield);

%% Stimulus and Suppressive Drive
stimdrive = zeros(size(stimdrivenRFs,2),size(inputStim,3));
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
    fprintf('>>>Predicted weigths for stimulus %d of %d\n', ii, size(inputStim,3));
end

% stimdriveIm = unflatten(stimdrive);
numeratorIm = unflatten(numeratorVec);
suppIm      = unflatten(respSurround);

%% population response
sptPopResp = numeratorIm ./ (suppIm + sigmaNorm);
predneuralweights = flatten(sptPopResp);
end