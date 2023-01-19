clear all; close all; clc;
load praxair


y = 1;
sig = .25;
sz = [1,1e4];
input = gauss(sz, y, sig);
fun = @(x,y) x + sqrt(x) - y;
input(1) = y;
for i = 1:numel(input)
    if input(i) < 0
        input(i) = gauss(1, y, sig);
    end
    err = @(x) fun(x,input(i));
    output(i) = fzero(err, [0, 2*y]);
end
[cnt, bins] = histcounts(output);
bins = conv(bins,[.5,.5],'valid');
[xData, yData] = prepareCurveData( bins, cnt );
% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [2/3*numel(sz) output(1) sig];

[fitresult, gof] = fit( xData, yData, ft, opts );
disp(['Histogram fit results: ', num2str(fitresult.c1/sqrt(2))])
estimation = abs(1/(1+1/(2*sqrt(output(1)))))*sig;
disp(['Algebraic estimation: ', num2str(estimation)])

clear all; close all; clc;

a = 3;
b = 15;
c = 1;
C = exp(c);
D = b + C;
y = a*D;
Y = @(in) in(1)*(in(2) + exp(in(3)));
da = 2;
db = 3;
dc = .5;
dC = C*dc;
dD = sqrt(db^2 + dC^2);
dy = y*sqrt((da/a)^2 + (dD/D)^2);

in = [a,b,c];
sig = [da, db, dc];
sz = 1e4;
input = zeros(sz,1);
output = zeros(sz,1);

for i = 1:numel(in)
    input(:,i) = gauss([sz,1], in(i), sig(i));
end
for i = 1:sz
    output(i) = Y(input(i,:));
end
[cnt, bins] = histcounts(output);
bins = conv(bins,[.5,.5],'valid');

[xData, yData] = prepareCurveData( bins, cnt );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [2/3*numel(sz) sum(in) sqrt(sum(sig.^2))];

[fitresult, gof] = fit( xData, yData, ft, opts );
disp(['Histogram fit results: ', num2str(fitresult.c1/sqrt(2))])
estimation = dy;
disp(['Algebraic estimation: ', num2str(estimation)])
histogram(output)
hold on
plot(fitresult)