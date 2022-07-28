% Set up workspace
clear all; clc; close all;
load NO_energy_data.mat
load N2O_data.mat
load praxair

names = fields(NO_energy_data);
order = [2,3,1,4];
names = {names{order}};
range = 1:4;

for i = range
    set = NO_energy_data.(names{i});
    for j = 1:size(set,1)
        id = set.Sample_name{j};
        rr31 = set.rr31(j);
        sa = N2O_data.(id)(1:3);
        ref = praxair.R_individual;
        doubles = N2O_data.(id)(4:6);
        s{i}(j,1) = measureScrambling(...
            sa,...
            ref,...
            rr31,...
            doubles);
    end
    I{i} = set.Intensity_mV;
end


bins = [0, 650, 700, 850, 1000, 1200, inf];
for i = range
        newI{i} = [];
        newS{i} = [];
        sigx{i} = [];
        sigy{i} = [];
    for j = 1:numel(bins)-1
        idx = find(and(I{i}>bins(j),I{i}<bins(j+1)));
        newI{i}(end+1) = mean(I{i}(idx));
        newS{i}(end+1) = mean(s{i}(idx));
        sigx{i}(end+1) = std(I{i}(idx));
        sigy{i}(end+1) = std(s{i}(idx));
    end
end

k = -1;
markers = {'*','v','o','^'};
lines = {':','--','-.','-'};
for i = range
    k = k+1;
    color = [k/4, 0, (4-k)/4];
    clr{i} = color;
    ft = scrambleTrend(I{i}, s{i});
    r = s{i} - feval(ft,I{i});
    sig = std(r);
    idx = find(abs(r)<(2*sig));
    s{i} = s{i}(idx);
    I{i} = I{i}(idx);
    [fit{i}, gof{i}, p(i), lim{i}] = scrambleTrend(I{i}, s{i});


    errorbar(newI{i}, newS{i},...
        -sigy{i},sigy{i},...
        -sigx{i},sigx{i},...
        markers{i},...
        'color', color);
%     plot(I{i}, s{i},...
%         markers{i},...
%         'color', color);
    hold on;
    xx = linspace(0, max(I{i})*1.1);
    yy = feval(fit{i},xx);
    plot(xx, yy,...
        lines{i},...
        'color',color);
    fit{i};
end
markers = {'*', 'v', 'o', '^'};

%% Modify display of the plot
xlim([400, 1600])
% ylim([0.083, 0.089])
ax = gca;
ax.XTick = [400, 1000, 1600];
ax.YTick = [0.083, 0.086, 0.089];
ylabel('Scrambling Coefficient')
xlabel('30 AMU Intensity (mV)')
eV = fliplr({'70 eV (*)',...
            ['90 eV (',char(9651),')'],...
            '110 eV (o)',...
            ['124 eV (',char(9661),')']});
legend([ax.Children(1:2:end)], eV, 'Location', 'SouthEast')
print_settings

for i = 1:4
tbl{1,i} = fit{i}.a;
if fit{i}.b < 1e-3
    tbl{2,i} = 0;
else
    tbl{2,i} = fit{i}.b;
end
tbl{3,i} = fit{i}.c;
tbl{4,i} = p(i);
tbl{5,i} = feval(fit{i},500);
if lim{i}(1) < 0.07
    tbl{6,i} = feval(fit{i},50);
else
    tbl{6,i} = lim{i}(1);
end
tbl{7,i} = lim{i}(1,2);
end
