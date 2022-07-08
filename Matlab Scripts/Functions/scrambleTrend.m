function [fitresult, gof, p, limits] = scrambleTrend(x,y)
%% Perform the fit
% if ~exist('w')
%     w = ones(size(x));
% end

% if ~exist('bounds')
%     bounds = [0,1,0];
% end
% [xData, yData, weights] = prepareCurveData(x, y, w);
[xData, yData] = prepareCurveData(x, y);

ft = fittype( '(a*x-b)/(1+c*(a*x-b))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.DiffMaxChange = 1;
opts.Display = 'Off';
opts.MaxFunEvals = 1000;
opts.Upper = [inf, 0, inf];
opts.Lower = [0, -inf, 0];
opts.MaxIter = 1000;
opts.Robust = 'LAR';
opts.StartPoint = [0.1 0 100];
opts.TolFun = 1e-08;
opts.TolX = 1e-08;
% opts.Weights = weights;

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