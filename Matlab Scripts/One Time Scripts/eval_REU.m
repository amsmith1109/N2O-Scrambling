% Set up workspace
clear all; clc; close all;
load REU
load N2O
load NO
load praxair

%% Get the 45R for each calibration sample
% refR picks out the praxair 15Ra, 15Rb and 17R for easy reference.
refR = [praxair.R15a, praxair.R15b, praxair.R17];

% names is calibration sample's names (e.g. A2, B1...)
names = fields(N2O);
for i = 1:numel(names)
    set = N2O.(names{i});
    for j = 1:numel(set)
        tempR45(j) = set{j}.R(1);
        tempR46(j) = set{j}.R(2);
    end
    tempR45 = mean(tempR45);
    tempR46 = mean(tempR46);
    R46_added = tempR46 - praxair.R18 - praxair.R17*praxair.R15a;
    double_added = R46_added/(praxair.R17 + praxair.R15a);
    Rvals(i) = tempR45;
    % Sample variable contains all measurement results. Here it is having
    % the 45R information and the known 15Ra, 15Rb, 17R that results from
    % it. The next loop adds NO fragment results.
    sample.(names{i}).R45 = tempR45; 
    %Consider modifying the added beta by raising the difference term to .994375
    sampleR15b = (tempR45 - praxair.R45) + praxair.R15b;
    sample.(names{i}).R_ind = [praxair.R15a, ...    %15Ra
                                    sampleR15b, ... %15Rb
                                    praxair.R17];   %17R
    sample.(names{i}).doubles = [praxair.R15a,...
                                tempR46 - praxair.R18 + praxair.R15b,...
                                praxair.R17];
    clear tempR45
    clear tempR46
end
% Rearrange names to index calibration samples in increasing enrichment.
% This later allows the plot to be color coded for enrichment.
[~,idx] = sort(Rvals);
names = names(idx);
%% Organize 31r data for determining scrambling coefficient
for i = 1:numel(names)
    % pick out the calibration sample for easy referencing
    set = NO.(names{i});
    % Grab intensity, and ion intensity ratios (31r) for the measurements
    % of the calibration sample and reference gas.
    for j = 1:numel(set)
        intensity(j) = mean(set{j}.sample(:,1));
        r = set{j}.r(1);
        tempr31(j) = r(1);
    end
    [intensity,idx] = sort(intensity);
    tempr31 = tempr31(idx);
    % Assign 31R values to 'sample'
    sample.(names{i}).intensity = intensity;
    sample.(names{i}).r31 = tempr31;
    clear tempr31 idx intensity
end

%% Obtain scrambling coefficients
xx = [];yy = [];
for i = 1:numel(names)
    for j = 1:numel(sample.(names{i}).r31)
        s = measureScrambling(...
            sample.(names{i}).R_ind,...
            refR,...
            sample.(names{i}).r31(j),...
            sample.(names{i}).doubles);
        sample.(names{i}).s(j) = s;
    end
    color = [(i-1)/10,0,(11-i)/10];
    [x,idx] = sort(sample.(names{i}).intensity);
    y = sample.(names{i}).s(idx);
    xx = [xx,x];
    yy = [yy,y];
    plot(x,y,'o','Color',color)
    hold on;
end

%% Perform logarithmic fit and plot the results
[xData, yData] = prepareCurveData(xx, yy);
ft = fittype( '(a*x+b)/(1+c*(a*x+b))', 'independent', 'x', 'dependent', 'y' );
%ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.001, 0.1, 0.1];
[fitresult, gof] = fit(xData, yData, ft, opts);

conf = confint(fitresult);

r2(i) = gof.rsquare;
plot(fitresult)
%txt = ['s = ',num2str(fitresult.a),' \times Log(V) + ',num2str(fitresult.b),'\newliner^2 = ',num2str(gof.rsquare)];
txt = ['$s = \frac{a\cdot I + b}',...
    '{1 + c(a\cdot I + b)}\\',...
    ', r^2 = ',num2str(gof.rsquare),'$'];
ylim([.99*min(yy),1.01*max(yy)])
xlim([.8*min(xx),1.01*max(xx)])
xlabel('30 AMU Intensity (mV)')
ylabel('Scrambling Coefficient')
print_settings
ax = gca;
ax.XTick = [250,2500,4500];
ax.YTick = [.086, .093];
ax.Children(1).LineWidth = 1.5;
ax.Children(1).Color = [0, 0, 0];
ax.Legend.Location = 'southeast';
p = predint(fitresult,x,.95,'observation','on');
plot(x,p,'r-')
lgd = legend([ax.Children(3)], txt);
lgd.Interpreter = 'latex';
lgd.FontSize = 12;

a = fitresult.a;
b = fitresult.b;
c = fitresult.c;
lower_limit = b/(1+b*c);
upper_limit = 1/c;

%set(lgd ,'Interpreter','latex')
% pf = predint(fitresult,x,.95,'function','on');
% plot(x,pf,'b-')
% legend([ax.Children(3),ax.Children(2)],txt,'95% Confidence of Observation')


%% Get R45, R31, and scrambling for each REU measurement
% for i = 1:6
%     REU.R45(i) = REU.N2O{i}.R(1);
%     REU.R46(i) = REU.N2O{i}.R(2);
%     REU.R_ind{i} = ...
%         [praxair.R15a, ...                              %15Ra
%         (REU.R45(i) - praxair.R45) + praxair.R15b, ...  %15Rb
%         praxair.R17];                                   %17R
%     REU.intensity(i) = mean(REU.NO{i}.sample(:,1));
%     REU.r31(i) = REU.NO{i}.r(1);
%     REU.s(i) = measureScrambling(...
%                                 REU.R_ind{i},...
%                                 refR,...
%                                 REU.r31(i),...
%                                 0.0173);
%     clr = REU.R45(i)/0.0177;
%     color = [0, clr, 1-clr];
%   
% end
% plot(REU.intensity,REU.s,'ko','MarkerSize',10,'LineWidth',3)