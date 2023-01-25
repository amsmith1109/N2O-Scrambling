% This script was used to compare R46 vs R45. It was here we discovered
% that the spike was adding double-substitutions that were not accounted
% for in the scrambling coefficient calculation.
%
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 24-Jan-2023
clear all; close all;
load N2O
load praxair
load N2O_data
names = fields(N2O);
for i= 1:numel(names)
    set = N2O.(names{i});
    for j = 1:numel(set)
        Rtemp = set{j}.delta(1);
        dtemp = set{j}.delta(2);
        if dtemp < 30
            1;
        end
        R45{i}(j) = Rtemp(1);
        d46{i}(j) = dtemp(1);
    end
%     plot(R45{i},d46{i},'o')
    R45av(i) = mean(R45{i});
    d46av(i) = mean(d46{i});
    hold on
end
ft = polyfit(R45av, d46av, 1);
plot(R45av, d46av, 'o')
hold on
plot(R45av,polyval(ft, R45av))

for i = 1:numel(names)
    R18 = praxair.R18;
    R = N2O_data.(names{i});
    doubles = R(4:6);
    R(4) = R18;
    val = invRM(R(1:4), 0.086, doubles);
    R46(i) = val(3);
end

d46 = sort((R46 ./ praxair.rref(3) - 1) * 1000);
plot(sort(R45av), sort(d46),'*')
xlabel('\delta^{45}')
ylabel('\delta^{46}')
legend('Measured','y = mx + b', 'Calculated')