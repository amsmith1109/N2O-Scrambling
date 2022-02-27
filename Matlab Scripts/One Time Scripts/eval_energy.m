%% Configure workspace
clear all; close all; clc;
load energy %varying energy data for 4 samples
load N2O %contains 45R data for all samples used
load praxair

refR = [praxair.R15a, praxair.R15b, praxair.R17];
names = fields(N2O);
for i = 1:numel(names)
    set = N2O.(names{i});
    for j = 1:numel(set)
        tempr = set{j}.r(1);
        tempR45(j) = tempr(1)*praxair.R45;
    end
    tempR45(find(isnan(tempR45))) = [];
    tempR45 = mean(tempR45);
    Rvals(i) = tempR45;
    sample.(names{i}).R45 = tempR45;
    sample.(names{i}).R_ind = ...
        [praxair.R15a, ...
        (tempR45 - praxair.R45) + praxair.R15b, ... %Consider modifying the added beta by raising the difference term to .994375
        praxair.R17];
    clear tempR45
end
%% Evaluate average 31R for varying energy experiment
e = [70,90,110,124];
experiments = fields(energy);
for i = 1:numel(experiments)
    names = fields(energy.(experiments{i}));
    for j = 1:numel(names)
        %% Get average 31R ratio for each sample
        R = [];
        for k = 1:numel(energy.(experiments{i}).(names{j}))
            d = energy.(experiments{i}).(names{j}){k};
            [R(k) err(k)] = Ratio(d);
            I(k) = intensity(d);
        end
        R31{i}.(names{j}) = mean(R);
        W31{i}.(names{j}) = sqrt(sum(err.^2));
    end
end

%% Get 45R values to determine scrambling
% names = fields(N2O);
for i = 1:numel(names)
    d = N2O.(names{i});
    R = [];
    for j = 1:numel(d)
        R(j) = Ratio(d{j},2);
    end
    R45.(names{i}) = mean(R);
%     d45.(names{i}) = (mean(R)/d{1}.refR(2)-1)*1000;
end

%% Determine Scrambling Ratio
for i = 1:4
    clear x; clear y;
    for j = 1:4
        y(j) = R31{i}.(names{j});
        x(j) = R45.(names{j});
        w(j) = W31{i}.(names{j});
    end
    [xData, yData, weights] = prepareCurveData( x, y, w );
    ft = fittype( 'poly1' );
    opts = fitoptions( 'Method', 'LinearLeastSquares' );
    opts.Weights = weights;
    [f, gof] = fit( xData, yData, ft, opts );
    s(i) = f.p1;
    conf = diff(confint(f),1)/2;
    W(i) = conf(1);
end

%% Plot results comparing scrambling coefficient vs ionization energy 
errorbar(e,s,W,'.','MarkerSize',30,'LineWidth',3,'CapSize',12)
xlim([60 130])
xlabel('Ionization Energy (eV)')
ylabel('Scrambling Coefficient')
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Calibri';
ax.XTick = [70 90 110 130];
ylab = ax.YTick;
ax.YTick = [ylab(1) ylab(end)];
ax.YTick = [ylab(1) mean(ax.YTick) ylab(end)];
print_settings;