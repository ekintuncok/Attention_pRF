function [CI_low, CI_high] = bootstrap_data2(number_of_iterations, data)
p = 68;
calculateCI = @(x,p)prctile(x,abs([0,100]-(100-p)/2));
bootstrapped_data = zeros(length(data),number_of_iterations);
for iter_idx = 1:number_of_iterations
    bootstrapped_data(:,iter_idx) = datasample(data, length(data));
end
bootstrapped_mean = mean(bootstrapped_data, 1);
CI = calculateCI(bootstrapped_mean, p);

CI_low  = CI(1);
CI_high = CI(2);

end