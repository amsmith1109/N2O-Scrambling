%% Configure workspace
clear all; close all; clc;
load energy %varying energy data for 4 samples
load N2O %contains 45R data for all samples used
load praxair
% fullscreen = 0; %Used by the print_settings script
%% Get the 45R for each calibration sample
% refR picks out the praxair 15Ra, 15Rb and 17R for easy reference.
refR = [praxair.R15a, praxair.R15b, praxair.R17];
% names is calibration sample's names (e.g. A2, B1...)
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
    % R45 variable contains all 45R for all calibration samples. This is
    % used to calculating s later.
    R45.(names{i}).R45 = tempR45; 
    % R_ind is the individual atom delta values.
    % R_ind(1) = 15N_alpha
    % R_ind(2) = 15N_beta
    % R_ind(3) = O17
    % Consider modifying the added beta by raising the difference term to .994375
    R45.(names{i}).R_ind = ...
        [praxair.R15a, ...                          %15Ra
        (tempR45 - praxair.R45) + praxair.R15b, ... %15Rb
        praxair.R17];                               %17R
    clear tempR45
end
% Rearrange names to index calibration samples in increasing enrichment.
% This later allows the plot to be color coded for enrichment.
[~,idx] = sort(Rvals);
names = names(idx);

%% Get 31r measurements from: 1) each experiment (index i) 2) each sample (index k)
experiments = fields(energy);
% Resort them to be done in order from lowest to highest ionization energy
e = [110,70,90,124];
[e,idx] = sort(e);
experiments = experiments(idx);
for i = 1:numel(experiments)
    names = fields(energy.(experiments{i}));
    for k = 1:numel(names)
    set = energy.(experiments{i}).(names{k});
    % Grab intensity, and ion intensity ratios (31r) for the measurements
    % of the calibration sample and reference gas.
    intensity = [];
    tempr31 = [];
    r31ref = [];
    for j = 1:numel(set)
        intensity(end+1) = mean(set{j}.sample(:,1));
    if intensity < 1200
        tempr = set{j}.r(1);
        tempr31(end+1) = tempr(1);
        r31ref(end+1) = mean(set{j}.reference(:,2)./set{j}.reference(:,1));
    else
        intensity(end) = [];
    end
    end
    [intensity,idx] = sort(intensity);
    tempr31 = tempr31(idx);
    r31ref = r31ref(idx);
    % Assign 31R values to 'sample'
    sample.(experiments{i}).(names{k}).intensity = intensity;
    sample.(experiments{i}).(names{k}).r31 = tempr31;
    sample.(experiments{i}).(names{k}).r31ref = r31ref;
    sample.(experiments{i}).(names{k}).R31 = tempr31*praxair.R31;
    sample.(experiments{i}).(names{k}).delta31 = (sample.(experiments{i}).(names{k}).R31/praxair.rref(1)-1)*1000;
%     clear tempr31 idx intensity
    end
end

%% Calculate scrambling coefficients for each measurement
fig = figure;
xlabel('30 AMU Intensity (mV)')
ylabel('Scrambling Coefficient')
for k = 1:numel(experiments)
xx = []; yy = [];
subplot(2,2,k)
for i = 1:numel(names)
    for j = 1:numel(sample.(experiments{k}).(names{i}).r31)
        s = measureScrambling(...
            R45.(names{i}).R_ind,...
            refR,...
            sample.(experiments{k}).(names{i}).r31(j)/...
            sample.(experiments{k}).(names{i}).r31ref(j));
        sample.(experiments{k}).(names{i}).s(j) = s;
    end
    color = [(i-1)/10,0,(11-i)/10];
    [x,idx] = sort(sample.(experiments{k}).(names{i}).intensity);
    y = sample.(experiments{k}).(names{i}).s(idx);
    xx = [xx,x];
    yy = [yy,y];
    plot(x,y,'o','Color',color)
    hold on;
end
%% Demonstrates Intensity dependence
[xData, yData] = prepareCurveData(xx, yy);
ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.001, 0.1];
[fitresult, gof] = fit(xData, yData, ft, opts);

conf = confint(fitresult);

r2(i) = gof.rsquare;
plot(fitresult)
txt = ['s = ',num2str(fitresult.a),' \times Log(V) + ',num2str(fitresult.b),'\newliner^2 = ',num2str(gof.rsquare)];
ylim([.99*min(yy),1.01*max(yy)])
xlim([.8*min(xx),1.01*max(xx)])
% xlabel('30 AMU Intensity (mV)')
% ylabel('Scrambling Coefficient')
xlabel('')
ylabel('')
print_settings
ax = gca;
legend([ax.Children(1)],txt)
ax.XTick = [500,1000];
ax.YLim = [.087, .095];
ax.YTick = [.087, .095];
ax.Children(1).LineWidth = 1.5;
ax.Children(1).Color = [0, 0, 0];
ax.Legend.Location = 'southeast';
legend('hide')
title([num2str(e(k)),' eV'])
smean(k) = mean(y); % Mean value for scrambling
ste(k) = std(y)/sqrt(numel(y)); % Calculate standard error
end
%% Apply axis labels outside the subplot
han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Scrambling Coefficient');
xlabel(han,'30 AMU Intensity (mV)');
p = han.YLabel.Position;
han.YLabel.Position(1) = p(1)*1.75;
%% Plot reduced results
figure
fullscreen = 0;
errorbar(e,smean,ste*1.95,'.','MarkerSize',10,'LineWidth',1.25,'CapSize',6)
xlabel('Ionization Energy (eV)')
ylabel('Scrambling \newline Coefficient')
print_settings
xlim([65,130])
xticks([70,90,110,124])
ylim([.088,.094])
yticks([.088,.091,.094])