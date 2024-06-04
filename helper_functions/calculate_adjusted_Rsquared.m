function adj_R2 = calculate_adjusted_Rsquared(R2, N, num_regressors)

adj_R2 = 1 - (((1-R2)*(N - 1))/(N - num_regressors - 1));

end