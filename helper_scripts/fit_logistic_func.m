function [params, recon_data, rsquare] = fit_logistic_func(data)
recon_data = cell(1, 4);
for cond = 1:size(data,2)
    curr_data = data{cond};
    if ~isnan(curr_data(1)) && size(curr_data,2) > 2
        t = 0:length(curr_data)-1;
        logistic_function = @(t, m, t_50) 1./(1 + exp(-m.*(t-t_50)));
        f = fittype('1 ./(1 + exp(-m.*(t-t_50)))','independent', 't', 'coefficients', {'m','t_50'});
        [fitresult, gof] = fit(t', curr_data', f,'StartPoint', [0, 1]);
        params(cond,:) =  [fitresult.m, fitresult.t_50];
        rsquare(cond) = gof.rsquare;
        recon_data{cond} = logistic_function(t, fitresult.m,  fitresult.t_50);
    else
        params(cond,:)  = [NaN, NaN];
        rsquare(cond) = NaN;
        recon_data{cond} = NaN;
    end
end