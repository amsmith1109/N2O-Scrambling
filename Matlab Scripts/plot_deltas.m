%% configure workspace
clear all; close all; clc;
folder = 'G:\Shared drives\Rice Lab Data\N2O\Scrambling\Pictures\RCM\delta vs I\';
load NO
load N2O
load praxair
leftColor = [0, .447, .741];
rightColor = [.85, .325, .098];
%% N2O Graphs Alone
% x_label=('Intensity (mV)');
% y_label=('\delta^{45} N_2O (�)');
% fname = [folder,'d45'];
% names = fields(N2O);
% for i = 1:numel(names)
%     set = N2O.(names{i});
%     [intensity, delta, uncertainty] = calcR(set);
%     f = plotter(intensity, delta, uncertainty, x_label,y_label,fname);
% end

%% NO Graphs Alone
% x_label=('Intensity (mV)');
% y_label=('\delta^{31} NO (�)');
% fname = [folder,'d31'];
% names = fields(NO);
% for i = 1:numel(names)
%     set = NO.(names{i});
%     [intensity, delta, uncertainty] = calcR(set);
%     f = plotter(intensity, delta, uncertainty, x_label,y_label,fname);
% end

%% Double Axis N2O & NO
x_label=('Intensity (mV)');
y_label1=('\delta^{31} NO (�)');
y_label2=('\delta^{45} N_2O (�)');
fname = [folder,'d45 and d31'];
names = fields(NO);
for i = 1:numel(names)
    set = NO.(names{i});
    [intensity, delta, uncertainty] = calcR(set,praxair.rref(1));
    D31(i) = mean(delta);
    err31(i) = 1.95*std(delta)/sqrt(numel(delta));
    set = N2O.(names{i});
    [intensity, delta, uncertainty] = calcR(set,praxair.rref(2));
    D45(i) = mean(delta);
end
figure
% errorbar(D45,D31,err31,'.','MarkerSize',10,'LineWidth',1.5,'CapSize',6)
ft = polyfit(D45,D31,1);
plot(D45,polyval(ft,D45),'r',D45,D31,'bo','LineWidth',1.5,'MarkerSize',5)
% hold on;
% plot(D45,D31,'bo','MarkerSize',5,'LineWidth',1.5)
ax = gca;
ax.XLabel.String = '\delta^{45} (�)';
ax.YLabel.String = '\delta^{31} (�)';
ax.XTick = [100,550,1000];
ax.YTick = [0,80,160];
ax.XLim = [0,1050];
slp = num2str(ft(1));
offset = num2str(ft(2));
% legend(ax.Children(2),['y = ',slp,'x + ',offset])
% legend('location','NorthWest')
fullscreen = 0;
print_settings;

names = fliplr({'A0','B0','C1','C2'});
fig = figure;
for i = 1:numel(names)
    subplot(2,2,i)
    %% First run NO on left axis
    set = NO.(names{i});
    [intensity, delta, uncertainty] = calcR(set,praxair.rref(1));
    yyaxis left
    plotter(intensity, delta, uncertainty, x_label, y_label1);
    ax = gca;
    ylimit = ax.YLim;
    dx = round(diff(ylimit)/2,1);
    mid = round(mean(ylimit),1);
    ax.YTick = [mid-dx,mid,mid+dx];
    ax.YLim = [ax.YTick(1),ax.YTick(end)];
    xrng = [ax.XTick(1),ax.XTick(end)];
    yrng = [ax.YTick(1),ax.YTick(end)];
    xloc = xrng(1)+.025*diff(xrng);
    yloc = yrng(end)-.075*diff(yrng);
    text(xloc,yloc,['(',i+64,')']);
    %% Run N2O on right axis, and scale Axis to match range of NO
    set = N2O.(names{i});
    [intensity, delta, uncertainty] = calcR(set,praxair.rref(2));
    D45(i) = mean(delta);
    yyaxis right
    plotter(intensity, delta, uncertainty, x_label,y_label2);
    ax = gca;
    mid_point = round(mean(ax.YLim),0);
    ax.YTick = [mid_point-dx,mid_point,mid_point+dx];
    ax.YLim = [ax.YTick(1), ax.YTick(end)];
    file = [fname,' - ',names{i}];
end
% variable han is used to place a single y axis label for the delta 31 plots
han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,'30/44 AMU Intensity (mV)')
q = han.XLabel.Position;
han.XLabel.Position(2) = q(2)*1.025;
yyaxis(han,'left')
p = han.YLabel.Position;
ylabel('\delta^{31} (�)')
han.YLabel.Position(1) = p(1)*1.625;
% I couldn't use han to set the right axis label, so I do it in a crude way
% below by assigning it to the 4th subplot, and shifting it to the right
% location.
ax = gca;
ax.YLabel.String = '\delta^{45} (�)';
ax.YLabel.Position(2) = 1019.75;


%% Cycle through plotting each sample
function [I,d,dW] = calcR(set,rref)
    R = [];
    I = [];
    for j = 1:numel(set)
        data = set{j};
        ratios = data.R(1);
        R(j) = ratios(1);
        W(j) = ratios(2);
        I(j) = mean([data.reference(:,1)]);
    end
    [I idx] = sort(I);
    R = R(idx);
    W = W(idx);
    j = 1;
    x = [];
    y = [];
    % The following loop consolidates neighboring intensity measurements
    while j<numel(I)
        if I(j+1)-I(j)<150
            % average and replace two neighboring values
            I(j) = mean(I(j:j+1));
            R(j) = mean(R(j:j+1));
            W(j) = sqrt(W(j)^2+W(j+1)^2);
            % kick the 2nd value to compress the vector
            I(j+1) = [];
            R(j+1) = [];
            W(j+1) = [];
            % otherwise, proceed to the next index
        else
            j = j+1;
        end
    end
    d = (R/rref-1)*1000;
    dW = 2*1.95*W*1000/rref;
end

function f = plotter(I,d,dW,xlab,ylab,fname)
%     f = figure;
    errorbar(I,d,dW,'.','MarkerSize',10,'LineWidth',1.5,'CapSize',6)
%     plot(I,d,'o','MarkerSize',10,'LineWidth',1.5)
%     xlabel(xlab)
%     ylabel(ylab)
    print_settings;
    xlim([0,4500])
    xticks([100,2250,4500])
end

function savefig(f,fname)
    file = [fname,'.fig'];
    saveas(f,file);
    file = [fname,'.png'];
    saveas(f,file);
end