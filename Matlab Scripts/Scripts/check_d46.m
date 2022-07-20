clear all; clc;

load('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO_data.mat')
load('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO_energy_data.mat')
load('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data.mat')
load('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\praxair.mat')

d1 = NO_energy_data.NO124eV;
d2 = NO_data;
for i = 1:numel(d1.Sample_name)
    name = d1.Sample_name{i};
    I(i) = d1.Intensity_mV(i);
    rr31 = d1.rr31(i);
    sa = N2O_data.(name);
    doubles = [sa(1),sa(end),sa(3)];
    s(i) = measureScrambling(sa(1:3),...
                            praxair.R_individual(1:3),...
                            rr31,...
                            doubles);
    
end                
plot(I,s,'o')

for i = 1:numel(d2.Sample_name)
    name = d2.Sample_name{i};
    I(i) = d2.Intensity_mV(i);
    rr31 = d2.rr31(i);
    sa = N2O_data.(name);
    doubles = [sa(1),sa(end),sa(3)];
    s(i) = measureScrambling(sa(1:3),...
                            praxair.R_individual(1:3),...
                            rr31,...
                            doubles);
    
end
hold on
plot(I,s,'.')
xlabel('Intensity (mV)')
ylabel('Scrambling')
legend('Energy Data', 'Intensity Data')