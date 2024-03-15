function fwhm = calculate_fwhm(X, Yv)
% 03/31/2023: Estimates the full-width half maximum of reconstructed
% attentional response data (Y). X represents binned polar angle distance
% values

% get the polar angle distance bin that produces the maximum attentional
% response

for v = 1:size(Yv,1)
    Y = Yv(v, :);
    
    if isnan(Y(1))
        fwhm(v) = NaN;    
    else
        [max_val, max_idx] = max(Y);
        % Find the half maximum value of the von Mises distribution
        half_max = max_val/2;
        half_max_idx = find(Y >= half_max, 1);

        % Calculate the FWHM of the von Mises distribution
        curr_fwhm = abs(X(half_max_idx) - X(max_idx));
        if ~isempty(curr_fwhm)
            fwhm(v) = abs(X(half_max_idx) - X(max_idx));
        end
    end
end
