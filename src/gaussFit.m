function [fitresult, err] = gaussFit(y)
    [cnt, bins] = histcounts(y);
    bins = conv(bins,[.5,.5],'valid');
    [xData, yData] = prepareCurveData(bins, cnt);
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [-Inf -Inf 0];
    opts.StartPoint = [0.3*numel(y), mean(y), std(y)];
    [fitresult, gof] = fit(xData, yData, ft, opts); % performs gauss fit
    err = fitresult.c1/(sqrt(2)*fitresult.b1)*100; % relative error in %
end

