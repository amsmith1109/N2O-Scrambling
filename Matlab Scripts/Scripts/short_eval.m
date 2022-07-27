clear all;  clc;
close all;
load praxair
load NO_data
load N2O_data

names = fields(N2O_data);
for i = 1:numel(names)
    R = N2O_data.(names{i});
    k(i) = R(2)/R(1);
    betas(i) = R(2);
end
[~,idx] = sort(betas);
names = {names{idx}};
c = max(k); clear k
for i = 1:numel(names)
    R = N2O_data.(names{i});
    dbl = R(4:6);
%     dbl = [R(1)*R(2),...
%            R(1)*R(3),...
%            R(2)*R(3)]
    k = R(2)/R(1);
    doubles = R(4:6);
    Intensity = NO_data.(names{i})(:, 1);
    rr31 = NO_data.(names{i})(:, 2);
    s = measureScrambling(R(1:3),...
                    praxair.R_individual,...
                    rr31,...
                    dbl);
    color = [(k-1)/(c-1), 0, 1 - k/c];
    plot(Intensity, s, 'o', 'color', color)
    hold on
end
