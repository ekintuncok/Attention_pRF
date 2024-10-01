function fwhm = calculate_fwhm(X, Yv)
% 03/31/2023: Estimates the full-width half maximum of reconstructed
% attentional response data (Y). X represents binned polar angle distance
% values

for v = 1:size(Yv,1)
    Y = Yv(v, :);
    
    if isnan(Y(1))
        fwhm(v) = NaN;    
    else
        d = Y - (max(Y)/2);
        ind = find(d > 0);
        fwhm(v) = abs(X(ind(end)) - X(ind(1)));
    end
end
