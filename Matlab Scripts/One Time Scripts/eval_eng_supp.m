eval_eng
close all;
clear intensity
clear x y dx dy ss xx yy
lgd = {'70eV','90eV','110eV','124eV'};
for i = 1:4
    intensity{i} = [];
    ss{i} = [];
    for j = 1:4
        set = sample.(experiments{i}).(names{j});
        intensity{i} = [intensity{i},set.intensity];
        ss{i} = [ss{i}, set.s];
    end
end

tops = [1100, 950, 800, 700, 600];
bots = [1000, 900, 750, 600, 500];

for i = 1:4
    filteredInt{i} = [];
    filteredSC{i} = [];
    xx = [];
    yy = [];
    color = [(4-i)/4,0,i/4];
    for j = 1:numel(tops)
        idx = find((intensity{i}<tops(j))&(intensity{i}>bots(j)));
        rawInt{i} = intensity{i}(idx);
        rawSC{i} = ss{i}(idx);
        x(j) = mean(rawInt{i});
        dx(j) = std(rawInt{i});
        y(j) = mean(rawSC{i});
        dy(j) = std(rawSC{i});
        % Filter
        jdx = find(abs((rawSC{i}-y(j)))>2*dy(j));
        if ~isempty(jdx)
            filteredInt{i} = [filteredInt{i},rawInt{i}(jdx)];
            filteredSC{i} = [filteredSC{i},rawSC{i}(jdx)];
            rawInt{i}(jdx) = [];
            rawSC{i}(jdx) = [];
            x(j) = mean(rawInt{i});
            dx(j) = std(rawInt{i})/sqrt(numel(rawInt{i}));
            y(j) = mean(rawSC{i});
            dy(j) = std(rawSC{i})/sqrt(numel(rawSC{i}));
        end
        xx = [xx,rawInt{i}];
        yy = [yy,rawSC{i}];
    end
[xData, yData, weights] = prepareCurveData( x, y, 1./dy );
% Set up fittype and options.
ft = fittype( 'a*log(x)+b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.5 0.5];
opts.Weights = weights;
[fitresult, gof] = fit( xData, yData, ft, opts );
%     figure
%     plot(intensity{i},ss{i},'ko')
%     plot(xx,yy,'ko')
%     hold on
%     plot(filteredInt{i},filteredSC{i},'bo')
%     plot(x,y,'r.','MarkerSize',30)
%     legend('Raw Data','Filtered Data','Average S')
    plot(fitresult)
    ax = gca;
    ax.Children(1).Color = color;
    hold on
    errorbar(x,y,-1*dy,dy,-1*dx,dx,'k.','MarkerSize',10,'Color',color)
    
%     legend('Raw Data','Average S')
    xlabel('Intensity (mV)')
    ylabel('Scrambling Coefficient')
end
ax = gca;
p = ax.Children;
legend([p(2:2:end)],lgd);
fullscreen = 1;
print_settings;