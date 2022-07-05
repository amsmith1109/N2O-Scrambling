clear all; close all; clc;
load praxair
%% Configure inputs
mu = linspace(0.078,0.082,3);
mu = 0.078;
sigma = 0.082;
R15a = praxair.R15a;
R17 = praxair.R17;
R18 = praxair.R18;
frac = [];

% delta-15x from Toyoda & Yoshida is given by:
% delta-15-beta = 15N14N16O/14N14N16O
% delta-15-alpha = 14N15N16O/14N14N16O
% The standard is vsmow & N2-air
% praxair has these as a hidden property. Below is 45R - 31R (unscrambled).
r_std = praxair.rref(2) - praxair.rref(1);


    sp_measured = [];
    sp = [];
%% Loop through the range to capture how variance in site preference changes
for z = linspace(0.97,1.12)
for i = mu
    R15b = praxair.R15b;
    R15a = praxair.R15a * z;
    d15a = (R15a/r_std-1)*1000;
    d15b = (R15b/r_std-1)*1000;
    sp(end+1) = d15a-d15b;
    R31 = R15a * (1 - i)...
        + R15b * i...
        + praxair.R17;
    R45 = R15a + R15b + R17;
    R46 = R15a*R15b...
        + R15a*R17...
        + R15b*R17...
        + R18;
    r_inds = rMeasure(R31, R45, R46, 0.085);
    d_inds = (r_inds./r_std - 1)*1000;
    sp_measured(end+1) = d_inds(1) - d_inds(2);
end

end
%     [N,edges] = histcounts(sp);
%     edges = conv(edges,[.5 .5],'valid');
%     [xData, yData] = prepareCurveData( edges, N );
%     fitresult = fit( xData, yData, ft, opts )
%plot(mu,sp)