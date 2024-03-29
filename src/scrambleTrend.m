% Description:
%   scrambleTrend - Performs an s-curve best fit on the input data.
%
%   This function calculates an s-curve best fit line on the input x and y
%   data. It is used to determine how scrambling varies with a given input
%   parameter (i.e., signal intensity). This function uses the aggregate of 
%   Scrambling values determined from raw calibration measurements that 
%   were analyzed with the measureScrambling function.
%
%% Example: 
%    [fitresult, gof, p, limits] = scrambleTrend(intensity, scrambling)
%    [~, ~, ~, limits] = scrambleTrend(intensity, scrambling)
%
%% Requirements:
%   Curve Fitting Toolbox
%
%% Inputs:
%   x = intensity (or other variable of interest), an n-length array
%   y = scrambling coefficient, an n-length array
%
%% Outputs:
%   fitresult = cfit object that has the fit parameters. It can be used to
%       calculate the uncertainty bounds of fit results.
%   gof = goodness of fit. Used to return statistical data
%   p = p-value for persistance of a trend. Null hypothesis is the first
%       coefficient is < 0.
%   limits = lower and upper limite of scrambling coefficient.
%   limits is a 2 x 2 matrix that includes two ranges of limits.
%   The top row is the min, max of the functional form
%   The bottom row is the min, max at 95% confidence of observed
%   a scrambling ratio. This represents a "worse-case" scenario.
%
%% Authorship:
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 05-Dec-2022
%% function:
function [fitresult, gof, p, limits] = scrambleTrend(x, y)

[xData, yData] = prepareCurveData(x, y);
    % Configure the curve fitting algorithm with values that typically
    % converge on an appropriate fit.
    ft = fittype( '(x/(a+b*x) + c)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.DiffMaxChange = 1;
    opts.Display = 'Off';
    opts.MaxFunEvals = 1000;
    opts.Upper = [inf, inf, inf];
    opts.Lower = [0, 0, 0];
    opts.MaxIter = 1000;
    opts.Robust = 'LAR';
    opts.StartPoint = [.1 0 100];
    opts.TolFun = 1e-08;
    opts.TolX = 1e-08;

    [fitresult, gof] = fit(xData, yData, ft, opts);
    confidence = confint(fitresult);
    
    % extract limits from the resulting fit
    a = fitresult.a;
    b = fitresult.b;
    c = fitresult.c;
    lower_limit = c;
    upper_limit = c + 1/b;
    observation_limit = predint(fitresult, [0,1e9], .95, 'observation','on');
    limits = [lower_limit, upper_limit; observation_limit(1), observation_limit(2,2)];

    % Calculate p-value for trend robustness
    linfit = lintest(xData, yData);
    confidence = confint(linfit, 0.68);
    sigma = (confidence(2,1) - confidence(1,1))/2;
    p = 1/2*(1 + erf(-linfit.p1/(sigma*sqrt(2))));
end

function [fitresult, gof] = lintest(x,y)
    [xData, yData] = prepareCurveData( x, y );
    ft = fittype( 'poly1' );
    [fitresult, gof] = fit( xData, yData, ft );
end
