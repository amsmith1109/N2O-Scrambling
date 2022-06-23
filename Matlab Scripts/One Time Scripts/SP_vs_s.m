clear all; close all; clc;
load praxair
%% Configure inputs
mu = linspace(0.05,0.15);
sigma = 0.01;
R15a = praxair.R15a;
R17 = praxair.R17;
R18 = praxair.R18;
sp = [];
%% Loop through the range to capture how variance in site preference changes
for i = mu
    R15b = praxair.R15b;
    R15a = praxair.R15a * 1.02;
    R31 = R15a * (1 - i)...
        + R15b * i...
        + praxair.R17;
    R45 = R15a + R15b + R17;
    R46 = R15a*R15b...
        + R15a*R17...
        + R15b*R17...
        + R18;
    r_inds = rMeasure(R31, R45, R46, 0.085);
    d_inds = (r_inds./praxair.R_individual - 1)*1000;
    sp(end+1) = d_inds(1) - d_inds(2);
end
%     [N,edges] = histcounts(sp);
%     edges = conv(edges,[.5 .5],'valid');
%     [xData, yData] = prepareCurveData( edges, N );
%     fitresult = fit( xData, yData, ft, opts )
plot(mu,sp)