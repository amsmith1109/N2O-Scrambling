function [fitresult, gof, p, limits] = scrambleTrend(x,y)
%% Perform the fit
[xData, yData] = prepareCurveData(x, y);
ft = fittype( '(a*x+b)/(1+c*(a*x+b))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.001, 1, 100];
[fitresult, gof] = fit(xData, yData, ft, opts);

conf = confint(fitresult);
%% extract limits
a = fitresult.a;
b = fitresult.b;
c = fitresult.c;
lower_limit = b/(1+b*c);
upper_limit = 1/c;
observation_limit = predint(fitresult, [0,1e9], .95, 'observation','on');
limits = [lower_limit, upper_limit; observation_limit(1), observation_limit(2,2)];

%% Calculate p-value for trend robustness
conf = confint(fitresult, 0.68);
sigma = (conf(2,1) - conf(1,1))/2;
%sig_zero = a/sigma;
p = 1/2*(1 + erf(-a/(sigma*sqrt(2))));
end