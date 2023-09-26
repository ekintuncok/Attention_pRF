function [output] = svd_regression(X, Y)
X = [ones(length(X),1) X];

[u,s,v]  = svd(X);
s_inv    =1./s';
s_inv(isinf(s_inv))=0;

betas = v*(s_inv*(u'*Y));
prediction = X*betas;
error = Y - prediction;
sq_error = (error(1:end)).^2;
error_avg = mean(sq_error);

output.betas = betas;
output.prediction = prediction;
output.sq_error = sq_error;
output.error_avg = error_avg;



