clear all; close all; clc;
load praxair
%% Configure inputs
range = 0:1:30;
mu = 0.09;
sigma = 0.01;
R15a = praxair.R15a;
R17 = praxair.R17;
R18 = praxair.R18;
sp_dev = [];
%% Prepare curve fitting settings
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.Normalize = 'off';
opts.StartPoint = rand(1, 3);
%% Loop through the range to capture how variance in site preference changes
for i = range
    s = gauss([1e2,1], mu, sigma);
    sp = [];
    %% Loop through each randomly generated s value
    for j = 1:numel(s)
        R15b = praxair.R15a * (1 + i/1e3);
        R31 = praxair.R15a * (1 - s(j))...
            + R15b * s(j)...
            + praxair.R17;
        R45 = R15a + R15b + R17;
        R46 = R15a*R15b...
            + R15a*R17...
            + R15b*R17...
            + R18;
        r_inds = rMeasure(R31, R45, R46, mu);
        d_inds = (r_inds./praxair.R_individual - 1)*1000;
        sp(j) = d_inds(1) - d_inds(2);
    end
%     [N,edges] = histcounts(sp);
%     edges = conv(edges,[.5 .5],'valid');
%     [xData, yData] = prepareCurveData( edges, N );
%     fitresult = fit( xData, yData, ft, opts )
    sp_dev(end+1) = std(sp);
end
plot(range,sp_dev)