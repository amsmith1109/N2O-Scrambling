%% eval_energy
%
% Script for analyzing varying electron energy results. These results are 
% shown in the main text as Table 2.
%
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 05-Jan-2023
%% Initialize workspace
clear all; clc; close all;
load all_NO_energy.mat
load N2O_data.mat
load praxair

names = fields(NO_energy_data);
range = 1:numel(names);
%% Grab data to analyze
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

%% Create binned values for plotting scrambling results
% This collects scrambling coefficients based on measured intensity.
% This portion of the script will run only if the user specifies
% plot_results to be true (or 1).
if plot_results
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
end

txt = {'70eV','80eV','90eV','100eV','110eV','120eV','124eV'};
%% Analyze data by run
for i = range
    ft = scrambleTrend(I{i}, s{i});
    r = s{i} - feval(ft,I{i});
    sig = std(r);
    idx = find(abs(r)<(2*sig));
    s{i} = s{i}(idx);
    I{i} = I{i}(idx);
    [fit{i}, gof{i}, p(i), lim{i}] = scrambleTrend(I{i}, s{i});
    %% Plotting results
    % This portion of the script will run only if the user specifies
    % plot_results to be true (or 1).
    if plot_results
        figure
        errorbar(newI{i}, newS{i},...
            -sigy{i},sigy{i},...
            -sigx{i},sigx{i},'o')
        hold on;
        xx = linspace(0, max(I{i})*1.1);
        yy = feval(fit{i},xx);
        plot(xx, yy)
        title(txt{i})
        xLimit = [0, 1600];
        xlim(xLimit)
        xlabel('[mV]')
        ylabel('[s]')
        py = polyfit(I{i}, s{i}, 1);
        plot(xLimit, polyval(py, xLimit))
    end
end

%% Collect results into a table.
% These results are shown in the main text as Table 2.
for i = range
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
row_names = {'a coefficient', 'b coefficient', 'c coefficient',... 
             'Trend p-value', 's at 500 mV', 'Lower limit of s',...
             'Upper limit of s'};
tbl = cell2table(tbl);
tbl.Properties.VariableNames = names.';
tbl.Properties.RowNames = row_names