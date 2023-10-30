function [x_intercept1, x_intercept2] = calculate_x_intercepts(fit_func, parameters)


X = (-180:1:180);
x_intercept1 = zeros(1, size(parameters,1));x_intercept2 = zeros(1, size(parameters,1));


switch fit_func
    case 'diff_von_mises'
        d_o_vonMises =  @(a1, a2, kappa1, kappa2, baseline, mu, x) a1*(exp((kappa1*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa1))) - a2*(exp((kappa2*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa2))) + baseline;

        for roi = 1:size(parameters,1)
            if isnan(parameters(roi,1))
                x_intercept1(1,roi) = NaN;
                x_intercept2(1,roi) = NaN;
            else
                a1        = parameters(roi,1);
                a2        = parameters(roi,2);
                kappa1   = parameters(roi,3);
                kappa2   = parameters(roi,4);
                baseline = parameters(roi,5);
                mu       = parameters(roi,6);

                reconsructed_curve = d_o_vonMises(a1, a2, kappa1, kappa2, baseline, mu, X);

                if any(reconsructed_curve > 0) && any(reconsructed_curve<0)
                    x_intercept1(1,roi) = fzero(@(x)d_o_vonMises(a1, a2, kappa1, kappa2, baseline, mu, x),-60);
                    x_intercept2(1,roi) = fzero(@(x)d_o_vonMises(a1, a2, kappa1, kappa2, baseline, mu, x),60);
                else
                    x_intercept1(1,roi) = NaN;
                    x_intercept2(1,roi) = NaN;
                end
            end
        end

    case 'von_mises'
        vonMises = @(a, kappa, baseline, mu,  x) a*(exp((kappa*cos(deg2rad(x) - mu)))/(2*pi*besseli(0,kappa))) + baseline;

        for roi = 1:size(parameters,1)
            if isnan(parameters(roi,1))
                x_intercept1(1,roi) = NaN;
                x_intercept2(1,roi) = NaN;
            else
                a        = parameters(roi,1);
                kappa1   = parameters(roi,2);
                baseline = parameters(roi,3);
                mu       = parameters(roi,4);

                reconsructed_curve = vonMises(a, kappa1, baseline, mu, X);

                if any(reconsructed_curve > 0) && any(reconsructed_curve<0)
                    x_intercept1(1,roi) = fzero(@(x)vonMises(a, kappa1, baseline, mu, x),-60);
                    x_intercept2(1,roi) = fzero(@(x)vonMises(a, kappa1, baseline, mu, x),60);
                else
                    x_intercept1(1,roi) = NaN;
                    x_intercept2(1,roi) = NaN;
                end
            end
        end
end

