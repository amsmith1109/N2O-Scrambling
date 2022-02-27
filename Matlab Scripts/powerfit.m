function out = powerfit(x,y)
    xData = log(x);
    yData = log(y);
    ft = polyfit(xData,yData,1);
    out = ft(1);
    out(2) = exp(ft(2));
end