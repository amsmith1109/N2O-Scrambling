clear all;  clc;
close all;
load praxair
load NO_data
load N2O_data
names = fields(N2O_data);
praxair.delta46 = praxair.delta46 - 1;
for i = 1:numel(names)
    R = N2O_data.(names{i});
    k(i) = R(2)/R(1);
    betas(i) = R(2);
end
[~,idx] = sort(betas);
names = {names{idx}};
c = max(k); clear k

xx = []; yy = [];
for i = 1:numel(names)
    R = N2O_data.(names{i});
    dbl = R(4:6);
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
    xx = [xx; Intensity];
    yy = [yy; s];
end
[fitresult, gof, pval, limits] = scrambleTrend(xx, yy);
plot(fitresult)
txt = ['$s = \frac{a\cdot U_{30} + b}',...
    '{1 + c(a\cdot U_{30} + b)}\\',...
    ', r^2 = ',num2str(gof.rsquare),'$'];
ylim([.99*min(yy), 1.01*max(yy)])
xlim([.8*min(xx), 1.01*max(xx)])
xlabel('30 m/z Intensity (mV)')
ylabel('Scrambling Coefficient')
fullscreen = 1;
print_settings
ax = gca;
ax.XTick = [250,2500,4500];
ax.YTick = [.082, .087];
ax.Children(1).LineWidth = 1.5;
ax.Children(1).Color = [0, 0, 0];
ax.Legend.Location = 'southeast';
p = predint(fitresult, sort(xx), .95, 'observation', 'on');
plot(sort(xx), p, 'r-')
lgd = legend([ax.Children(3)], txt);
lgd.Interpreter = 'latex';
lgd.FontSize = 12;
fitresult
feval(fitresult, 0)
feval(fitresult, 500)
1/fitresult.c