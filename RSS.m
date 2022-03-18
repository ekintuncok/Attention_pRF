function popRSS = RSS(currData, attx0, atty0, stim,stim_ecc, stimdrivenRFs, params)
                        
    predneuralweights = normalizationmodel(stim, stim_ecc, stimdrivenRFs, attx0, atty0,...
         params(1), params(2), params(3));
    resSumSq = zeros(1, length(predneuralweights));
    
for voxel = 1:length(predneuralweights)  
    Y=currData(voxel,:);
    X = predneuralweights(voxel,:);
    X = X';
    Y = Y';
    Xs = [ones(length(X),1) X];
    b = Xs\Y;
    resSumSq(voxel) = sum((Y - b(1) - b(2)*X).^2);
end
   popRSS = mean(resSumSq);
end