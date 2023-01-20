clear all; close all; clc;
load praxair

s = 0.08;
ds = s*.05;
idx = 1;
% Using reference gas values as mean values to evaluate error propagation.
R31 = praxair.R15a*(1 - s)...
    + praxair.R15b*s...
    + praxair.R17; % Convert to the measured equivalent.
R45 = praxair.R45;
R46 = praxair.R46;
y = [R31, R45, R46];

% Suppose relative error of 1% for R46, 10% for others. If uncertainty is
% primarily determined by the R46 measurement, the ending uncertainty
% should be close to 1% for R18.
sig = [y(1)*0.0, y(2)*0.0, y(3)*.0]; 

% Create random error measurements
sz = 1e4;
for i = 1:3
    input(:,i) = gauss([1,sz], y(i), sig(i));
end
sIN = gauss([1,sz], s, ds);
for i = 1:sz
    output(i,:) = rMeasure(input(i,:), sIN(i));
end
sp = output(:,1) - output(:,2);
% Pick out and evaluted uncertainty for R18 measurement
[cnt, bins] = histcounts(output(:, idx));
bins = conv(bins,[.5,.5],'valid');
[xData, yData] = prepareCurveData( bins, cnt );
% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [0.3*numel(sz), praxair.R_individual(idx), ds];
[fitresult, gof] = fit( xData, yData, ft, opts ); % performs gauss fit
err = fitresult.c1/sqrt(2)/praxair.R_individual(idx)*100;
disp(['Histogram fit results: ', num2str(err), '%'])
histogram(output(:,idx))
hold on
plot(fitresult)

% y = 1;
% sig = .25;
% sz = [1,1e4];
% input = gauss(sz, y, sig);
% fun = @(x,y) x + sqrt(x) - y;
% input(1) = y;
% for i = 1:numel(input)
%     if input(i) < 0
%         input(i) = gauss(1, y, sig);
%     end
%     err = @(x) fun(x,input(i));
%     output(i) = fzero(err, [0, 2*y]);
% end
% [cnt, bins] = histcounts(output);
% bins = conv(bins,[.5,.5],'valid');
% [xData, yData] = prepareCurveData( bins, cnt );
% % Set up fittype and options.
% ft = fittype( 'gauss1' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.Lower = [-Inf -Inf 0];
% opts.StartPoint = [2/3*numel(sz) output(1) sig];
% 
% [fitresult, gof] = fit( xData, yData, ft, opts );
% disp(['Histogram fit results: ', num2str(fitresult.c1/sqrt(2))])
% estimation = abs(1/(1+1/(2*sqrt(output(1)))))*sig;
% disp(['Algebraic estimation: ', num2str(estimation)])
% 
% clear all; close all; clc;
% 
% a = 3;
% b = 15;
% c = 1;
% C = exp(c);
% D = b + C;
% y = a*D;
% Y = @(in) in(1)*(in(2) + exp(in(3)));
% da = 2;
% db = 3;
% dc = .5;
% dC = C*dc;
% dD = sqrt(db^2 + dC^2);
% dy = y*sqrt((da/a)^2 + (dD/D)^2);
% 
% in = [a,b,c];
% sig = [da, db, dc];
% sz = 1e4;
% input = zeros(sz,1);
% output = zeros(sz,1);
% 
% for i = 1:numel(in)
%     input(:,i) = gauss([sz,1], in(i), sig(i));
% end
% for i = 1:sz
%     output(i) = Y(input(i,:));
% end
% [cnt, bins] = histcounts(output);
% bins = conv(bins,[.5,.5],'valid');
% 
% [xData, yData] = prepareCurveData( bins, cnt );
% 
% % Set up fittype and options.
% ft = fittype( 'gauss1' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.Lower = [-Inf -Inf 0];
% opts.StartPoint = [2/3*numel(sz) sum(in) sqrt(sum(sig.^2))];
% 
% [fitresult, gof] = fit( xData, yData, ft, opts );
% disp(['Histogram fit results: ', num2str(fitresult.c1/sqrt(2))])
% estimation = dy;
% disp(['Algebraic estimation: ', num2str(estimation)])
% histogram(output)
% hold on
% plot(fitresult)