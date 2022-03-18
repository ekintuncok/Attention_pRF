function rss = fitpRF_rss(currData, stim, spacegrid, rfparams)

% pad stimulus with zeros to avoid edge artifacts
ecc = linspace(-10,10,spacegrid);
[X,Y] = meshgrid(ecc,ecc);
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
inputStim = reshape(inputStim, spacegrid*spacegrid, []);
[RF,RFvec] = createGauissanFields(X,Y,rfparams(1),rfparams(2),rfparams(3));
% vectorize the stim input:
% prediction is the product of the stim matrix with RFs
pred = RFvec*inputStim;
% get the beta vals for regions of interest
b = mldivide(pred',currData');
rss = sum((currData - b*pred).^2);
end

