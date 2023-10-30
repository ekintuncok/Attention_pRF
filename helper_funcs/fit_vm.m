function [est_params, recon_data, rsquare] = fit_vm(fit_func, X, Y)

est_params = [];
recon_data = zeros(size(Y));
rsquare = zeros(1,size(Y,1));

for roi = 1:size(Y,1)
    curr_Y = Y(roi,:);

    switch fit_func
        case 'von_mises'
            if isnan(curr_Y(1))
                est_params = cat(1, est_params, [NaN, NaN, NaN, NaN]);
                recon_data(roi, :) = NaN(size(X));
                rsquare(1,roi) = NaN;
            else
                % define the von Mises function:
                vonMises = @(a, kappa, baseline, mu,  x) a*(exp((kappa*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa))) + baseline;
                f = fittype(' a*(exp((kappa*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa))) + baseline','independent', 'x', 'coefficients', {'a', 'kappa', 'baseline', 'mu'});
                fo = fitoptions('MaxFunEvals',1500, ...
                    'MaxIter',1500,'Method', 'NonlinearLeastSquares', 'StartPoint', [0.5, 0, 0, 0]);
                [fitresult, gof] = fit(X', curr_Y', f, fo);
                rsquare(1,roi) = gof.rsquare;
                est_params = cat(1, est_params, [fitresult.a, fitresult.kappa, fitresult.baseline,  fitresult.mu]);
                recon_data(roi, :) = vonMises(est_params(roi,1), est_params(roi,2), est_params(roi,3),est_params(roi,4), X);
            end
        case 'diff_von_mises'
            if isnan(curr_Y(1))
                est_params = cat(1, est_params, [NaN, NaN, NaN, NaN, NaN, NaN]);
                recon_data(roi, :) = NaN(size(X));
                rsquare(1,roi) = NaN;
            else

                % Define the difference of Von Mises distribution
                d_o_vonMises =  @(a1, a2, kappa1, kappa2, baseline, mu, x) a1*(exp((kappa1*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa1))) - a2*(exp((kappa2*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa2))) + baseline;
                f = fittype('a1*(exp((kappa1*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa1))) - a2*(exp((kappa2*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa2))) + baseline', ...
                    'independent', 'x', 'coefficients', {'a1','a2', 'kappa1','kappa2', 'baseline','mu'});
               
                fo = fitoptions('Normalize','off',...
                    'MaxFunEvals',1500, ...
                    'MaxIter',1500, 'Method', 'NonlinearLeastSquares', ...
                    'StartPoint', [10, 10, 2, 1,1,-0.1], 'Lower', [0,0, 0, 0, -1, -pi], 'Upper', [Inf,Inf, Inf, Inf, 1, pi]);
                [fitresult, gof] = fit(X', curr_Y', f, fo);
                rsquare(1,roi) = gof.rsquare;
                est_params = cat(1, est_params, [fitresult.a1,fitresult.a2, fitresult.kappa1, fitresult.kappa2, fitresult.baseline, fitresult.mu]);
                recon_data(roi, :) = d_o_vonMises(est_params(roi,1), est_params(roi,2), est_params(roi,3), est_params(roi,4),  est_params(roi,5),est_params(roi,6), X);
            end
    end
end
end
