clear all; clc; close all;
%% Load in the raw data
A = csvread('Reduced NO & N2O and Weights.csv');
I = A(:,1); % Signal Intensity
R = A(:,2); % Measured 45 AMU / 44 AMU ratios
r = A(:,3); % Measured 31 AMU / 30 AMU ratios
w = A(:,4); % weights corresponding to uncertainty in r
index_end = 0;
%% loop configured for finding the 14 scrambling coefficients
for i = 1:13 %I know there are 13 different intensities to evaluate
%% Find where the block of data is that belongs to a single intensity
index_start = index_end+1;
index_end = find(I==I(index_end+1),1,'last');
Intensity(i) = I(index_start);
block = index_start:index_end;
%% Determine the scrambling coefficients for each intensity
x = R(block);
y = r(block);
ww = w(block);

[xData, yData, weights] = prepareCurveData( x, y, ww );
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Weights = weights;
[f, gof] = fit( xData, yData, ft, opts );

s(i) = f.p1;
conf = diff(confint(f),1);
W(i) = conf(1)/2;
r2(i) = gof.rsquare;
end

[xData, yData, weights] = prepareCurveData( Intensity, s, W );
ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.864833962001789 0.393244022961477];
opts.Weights = weights;
[fitresult, gof] = fit( xData, yData, ft, opts );

errorbar(Intensity,s,W,'.','MarkerSize',20,'LineWidth',3,'CapSize',12)

% plot(Intensity,s,'bo')
hold on
plot(fitresult)
ylim([.99*min(s),1.01*max(s)])
format short
ax = gca;
ax.Legend.Location='NorthWest'
legend('Scrambling Coefficient',['s = ',num2str(fitresult.a),'\times Log(V) + ',num2str(fitresult.b),'\newliner^2 = ',num2str(gof.rsquare)],'Location','SouthEast')
ax.XTick = [0,2000,4000];
ax.YTick = [.082,.084,.086];
xlabel('Intensity (mV)')
ylabel('Scrambling Coefficient')
ax.Children(1).LineWidth = 2;
ax.Children(2).LineWidth = 1.5;
print_settings;
% ax.Children(2).MarkerSize = 10;
% function [fit,err,r2] = lfit(x,y,w)
%     n = numel(x);
%     X = [reshape(x,[],1),ones(n,1)];
%     [U,S,V] = svd(X.'*diag(w)*X);
%     cov = U*pinv(S)*V.';
%     fit = cov*X.'*diag(w)*reshape(y,[],1);
%     model = polyval(fit,x);
%     
%     SSR = sum((y-model).^2);
%     SST = sum((y-mean(y)).^2);
%     r2 = 1-SSR/SST;
%     
%     err = sqrt(diag(cov)*SSR)*1.96;
% end