% Unpublished Result
%
% This script was used to check if errors in the scrambling versus signal 
% intensity plot were indeed gaussian.
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 25-Jan-2023
close all; clear all; clc;

load Intensity_Residuals
bins = residual.hist(:,1);
counts = residual.hist(:,2);
[xData, yData] = prepareCurveData( bins, counts );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [2719 0.00015 0.00102864220494136];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
histogram(residual.data)
hold on
xx = linspace(min(xData),max(xData));
yy = feval(fitresult, xx);
h = plot( xx, yy ,'LineWidth',3);
% Label axes
xlabel residuals



