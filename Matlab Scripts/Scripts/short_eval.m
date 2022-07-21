clear all;  clc;
close all;
load praxair
load NO_data
load N2O_data
names = fields(N2O_data);

for i = 1:numel(names)
    R = N2O_data.(names{i});
    k = R(2)/R(1);
    doubles = R(4:6);
    Intensity = NO_data.(names{i})(:, 1);
    rr31 = NO_data.(names{i})(:, 2);
    s = measureScrambling(R(1:3),...
                    praxair.R_individual,...
                    rr31,...
                    R(1:3));
    color = [(k-1)/2.16, 0, 1 - k/3.16];
    plot(Intensity, s, 'o', 'color', color)
    hold on
end
