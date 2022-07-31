% This script was used to calculate the changes in site-preference accuracy
% that is discussed in the Discussion portion of the paper.
% 
% This script generates a ficticious sample that has been enriched or
% depleted in the alpha position. It generates what type of measurement the
% IRMS would return with a given "true" scrambling coefficient, and
% calculates the site-preference based on the "calibration" scrambling
% coefficient.
%
% Warning:
% This was a working file and was edited multiple times for checking
% different configurations. Whatever is saved here is just the last version
% of it.
%
% It originated from the sp_bootstrap_text.m file, and many parts have not
% been cleaned up. The important part is to make sure that in the loop, s
% is used for calculating the anticipated voltage ratio, and s0 is the
% scrambling coefficient used for calculating the individual ratios.

clear all; close all; clc;
load praxair
%% Configure inputs

s = 0.085;
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
    d15a = (R15a/r_std - 1)*1000;
    d15b = (R15b/r_std - 1)*1000;
    sp(end+1) = d15a-d15b;
    R31 = R15a * (1 - i)...
        + R15b * i...
        + praxair.R17;
    R45 = R15a + R15b + R17;
    R46 = R15a*R15b...
        + R15a*R17...
        + R15b*R17...
        + R18;
    r_inds = rMeasure(R31, R45, R46, s);
    d_inds = (r_inds./r_std - 1)*1000;
    sp_measured(end+1) = d_inds(1) - d_inds(2);
end

end
polyfit(sp, sp_measured, 1)
