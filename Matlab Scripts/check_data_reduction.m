% check_data_reduction - script
%
% The purpose of this script is for informational purposes only. It plots
% the sub-sampled set of 124 eV electron energy against the full set used
% in the scrambling vs signal intensity plot (figure 3 in the main text).
% This highlights that a limited sample is subject to bias and may be
% insufficient at verifying a trend of scrambling vs signal intensity.
%
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 24-Jan-2023
clear all; clc; close all;

load NO_data_table
load NO_energy_data
load N2O_data
load praxair

d1 = NO_energy_data.NO124eV;
d2 = NO_data_table;
for i = 1:numel(d1.Sample_name)
    name = d1.Sample_name{i};
    I(i) = d1.Intensity_mV(i);
    rr31 = d1.rr31(i);
    sa = N2O_data.(name);
    doubles = [sa(1),sa(end),sa(3)];
    s(i) = measureScrambling(sa(1:3),...
                            praxair.R_individual,...
                            rr31,...
                            sa(4:6));
    
end                
plot(I,s,'o')

for i = 1:numel(d2.Sample_name)
    name = d2.Sample_name{i};
    I(i) = d2.Intensity_mV(i);
    rr31 = d2.rr31(i);
    sa = N2O_data.(name);
    doubles = [sa(1),sa(end),sa(3)];
    s(i) = measureScrambling(sa(1:3),...
                            praxair.R_individual,...
                            rr31,...
                            sa(4:6));
    
end
hold on
plot(I,s,'.')
xlabel('Intensity (mV)')
ylabel('Scrambling')
legend('Energy Data', 'Intensity Data')