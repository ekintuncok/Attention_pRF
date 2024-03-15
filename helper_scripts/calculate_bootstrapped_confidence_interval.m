function [lower_ci, upper_ci] = calculate_bootstrapped_confidence_interval(data, param)

if strcmp(param, 'mn')
    fnc = @mean;
elseif strcmp(param, 'mdn')
    fnc = @median;
end

num_samples = 10000;
CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;

ci_all = zeros(2, size(data, 2));

for cond = 1:size(data, 2)
    boot_data = bootstrp(num_samples, fnc, data(:, cond));
    ci_all(:, cond) = prctile(boot_data, [low_prct_range, high_prct_range]);
end

lower_ci = ci_all(1,:);
upper_ci = ci_all(2,:);