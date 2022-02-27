% Set up workspace
clear all; clc; close all;
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
        r = set{j}.r(1);
        tempR45(j) = r(1)*praxair.R45;
    end
    tempR45(find(isnan(tempR45))) = [];
    tempR45 = mean(tempR45);
    Rvals(i) = tempR45;
    % Sample variable contains all measurement results. Here it is having
    % the 45R information and the known 15Ra, 15Rb, 17R that results from
    % it. The next loop adds NO fragment results.
    sample.(names{i}).R45 = tempR45; 
    %Consider modifying the added beta by raising the difference term to .994375
    sample.(names{i}).R_ind = ...
        [praxair.R15a, ...                          %15Ra
        (tempR45 - praxair.R45) + praxair.R15b, ... %15Rb
        praxair.R17];                               %17R
    clear tempR45
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
        r31ref(j) = mean(set{j}.reference(:,2)./set{j}.reference(:,1));
    end
    [intensity,idx] = sort(intensity);
    tempr31 = tempr31(idx);
    % Assign 31R values to 'sample'
    sample.(names{i}).intensity = intensity;
    sample.(names{i}).r31 = tempr31;
    sample.(names{i}).r31ref = r31ref;
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
            sample.(names{i}).r31ref(j));
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
% pf = predint(fitresult,x,.95,'function','on');
% plot(x,pf,'b-')
legend([ax.Children(3),ax.Children(2)],txt,'95% Confidence of Observation')


%% Sensitivity Test for varying scrambling of 14N15N16O (\kappa)
% +/- 10% shift in \kappa is approximately equal to the 95% confidence
% interval of observed scrambling coefficients.

% figure 
% xx = [];yy = [];
% for i = 1:numel(names)
%     for j = 1:numel(sample.(names{i}).r31)
%         s = measureScrambling(...
%             sample.(names{i}).R_ind,...
%             refR,...
%             sample.(names{i}).r31(j),...
%             sample.(names{i}).r31ref(j),...
%             .9);
%         sample.(names{i}).s(:,j) = s(1);
%     end
%     color = [(i-1)/10,0,(11-i)/10];
%     [x,idx] = sort(sample.(names{i}).intensity);
%     y = sample.(names{i}).s(idx);
%     xx = [xx,x];
%     yy = [yy,y];
% %     plot(x,y,'o','Color',color)
%     hold on;
% end
% [xData, yData] = prepareCurveData(xx, yy);
% ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0.001, 0.1];
% [fitresult, gof] = fit(xData, yData, ft, opts);
% plot(fitresult)
% legend(names)
% % figure
% xx = [];yy = [];
% for i = 1:numel(names)
%     for j = 1:numel(sample.(names{i}).r31)
%         s = measureScrambling(...
%             sample.(names{i}).R_ind,...
%             refR,...
%             sample.(names{i}).r31(j),...
%             sample.(names{i}).r31ref(j),...
%             1.1);
%         sample.(names{i}).s(:,j) = s(1);
%     end
%     color = [(i-1)/10,0,(11-i)/10];
%     [x,idx] = sort(sample.(names{i}).intensity);
%     y = sample.(names{i}).s(idx);
%     xx = [xx,x];
%     yy = [yy,y];
% %     plot(x,y,'o','Color',color)
%     hold on;
% end
% [xData, yData] = prepareCurveData(xx, yy);
% ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0.001, 0.1];
% [fitresult, gof] = fit(xData, yData, ft, opts);
% plot(fitresult)
% legend(names)