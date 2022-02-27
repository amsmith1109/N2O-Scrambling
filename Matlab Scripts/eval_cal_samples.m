close all; clear all; clc;
load N2O; load NO; load praxair;
names = fields(N2O);
for i = 1:numel(names)
    R = [];
    for j = 1:numel(N2O.(names{i}))
        R(end+1) = N2O.(names{i}){j}.r(2)*praxair.R45;
    end
    R45.(names{i}).value = mean(R);
    if isnan(mean(R))
        1;
    end
    R45.(names{i}).error = std(R);
    clear R
end

