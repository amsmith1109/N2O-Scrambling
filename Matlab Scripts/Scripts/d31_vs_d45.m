%% Set up workspace
clear all; 
% clc; 
close all;
load N2O
load NO
load praxair

%% N2O Data reduction
% results are a table with the following:
% Sample name, R15a, R15b, R17, R15b_doubles
names = fields(N2O);
n = numel(names);
for i = 1:n
    R = [];
    I = [];
    set = N2O.(names{i});
    for j = 1:numel(set)
        R(j) = set{j}.R(1);
        I(j) = mean(set{j}.sample(:,1));
    end
    [I, idx] = sort(I);
    R = R(idx);
    data.min(i,1) = mean(R(1:2));
    data.max(i,1) = mean(R(end-3:end-2));
end

%% NO Data Reduction
for i = 1:n
    R = [];
    I = [];
    set = NO.(names{i});
    for j = 1:numel(set)
        R(j) = set{j}.R(1);
        I(j) = mean(set{j}.sample(:,1));
    end
    [I, idx] = sort(I);
    R = R(idx);
    data.min(i,2) = mean(R(1:2));
    data.max(i,2) = mean(R(end-3:end-2));
end
data.min = sort(data.min);
data.max = sort(data.max);
data.min_delta(:,1) = (data.min(:,1)./praxair.rref(2)-1)*1000;
data.min_delta(:,2) = (data.min(:,2)./praxair.rref(1)-1)*1000;
data.max_delta(:,1) = (data.max(:,1)./praxair.rref(2)-1)*1000;
data.max_delta(:,2) = (data.max(:,2)./praxair.rref(1)-1)*1000;
plot(data.max_delta(:,1), data.max_delta(:,2), 'ro')
hold on
plot(data.min_delta(:,1), data.min_delta(:,2), 'b^')

minimum = [data.min_delta(1,1), data.min_delta(1,2)];
plot(minimum(1), minimum(2),'ko')

y(1) = data.max_delta(end,2);
y(2) = data.min_delta(end,2);
x = data.max_delta(end,1);

xlim([0, 1100])
% text(x,mean(y),'\fontsize{10}\}')
text(x + 10, mean(y) + 1, '\} 8‰');
text(minimum(1) + 30 , minimum(2) - 5, 'No enrichment');
xlabel('\delta^{45} (‰)');
ax = gca;
ylabel('\delta^{31} (‰)');

ft = polyfit(data.max_delta(1:2,1), data.max_delta(1:2,2), 1);
ft2 = polyfit(data.min_delta(1:2,1), data.min_delta(1:2,2), 1);

xx = [0, 1e3];
yy = polyval(ft, xx);
yy2 = polyval(ft2, xx);
plot(xx, yy, 'r--')
plot(xx, yy2, 'b-.')
legend([ax.Children(1:2)],...
    '(\Delta) 250 mV' ,...
    '(o) 4,000 mV' ,...
    'Location', 'SouthEast');
print_settings;

s = @(ref, slope) (slope * ref.rref(1) * (ref.R15b + 1)) / ...
    (ref.rref(2) + slope * ref.rref(1) * (ref.R15b - ref.R15a));

% range = [s(praxair, ft2(1)), s(praxair, ft(1))]
% [ft(2), ft2(2)]

R31 = praxair.rref(1);
R45 = praxair.rref(2);
R15a = praxair.R15a;
R15b = praxair.R15b;
R17 = praxair.R17;
d31_m = data.min_delta(:,2);
d45_m = data.min_delta(:,1);
% Note that the d45 in the denominator has to be divided by 1000 to get rid
% of the permil units for determining beta-added. The units remain in the
% d45 in the numerator so that both sides have the same units.
d31_p = @(d45, s) R45/R31 * d45 * (s + R17 + R15a) ./ (1 + s*R15a + (1-s)*(R15b + R45*d45/1000));
fun = @(s) sum((d31_p(d45_m,s) - d31_m).^2);
fminsearch(fun,.08)