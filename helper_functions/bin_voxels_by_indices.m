function [xbinned, ybinned, counts] = bin_voxels_by_indices(X, Y, indices, binWidth)

Xtemp = X(indices);
Ytemp = Y(indices);

x = Xtemp(~isnan(Xtemp));
y = Ytemp(~isnan(Ytemp));

xbinned = [];
ybinned = [];
counts = [];

for binInd = 1:length(binWidth)
    if binInd ~= length(binWidth)
        currBin = find(x >= binWidth(binInd) & x <= binWidth(binInd+1));
    else
        currBin = find(x >= binWidth(binInd) & x <= binWidth(binInd)+1);
    end
    xbinned = [xbinned; median(x(currBin), 'omitnan')];
    ybinned = [ybinned; median(y(currBin), 'omitnan')];
    indices_fr_bin = binInd*ones(size(y(currBin)));
    counts = [counts; [indices_fr_bin, y(currBin)]];
end


xbinned = xbinned';
ybinned = ybinned';
