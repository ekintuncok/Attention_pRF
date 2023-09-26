function [xbinned, ybinned] = bin_voxels_by_indices(X, Y, indices, binWidth)

Xtemp = X(indices);
Ytemp = Y(indices);

x = X(~isnan(Xtemp));
y = Y(~isnan(Ytemp));

xbinned = [];
ybinned = [];

for binInd = 1:length(binWidth)
    if binInd ~= length(binWidth)
        currBin = find(x >= binWidth(binInd) & x <= binWidth(binInd+1));
    else
        currBin = find(x >= binWidth(binInd));
    end
    xbinned = [xbinned; mean(x(currBin), 'omitnan')];
    ybinned = [ybinned; mean(y(currBin), 'omitnan')];
end


xbinned = xbinned';
ybinned = ybinned';
