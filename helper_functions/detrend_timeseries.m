function detrended_timeseries = detrend_timeseries(timeseries)

total_TRs = size(timeseries,2);
model_constant = ones(total_TRs,1);
model_drift = 1:total_TRs;
model_matrix = cat(2, model_constant, model_drift');


% [U,S,V] = svd(model_matrix);
% S_inv = 1./S';
% S_inv(isinf(S_inv)) = 0;
% betas = V * S_inv * U' * timeseries';

betas = model_matrix\timeseries';

model_predictions = (model_matrix * betas)';
detrended_timeseries = timeseries - model_predictions;

end