ax = gca;
ax.FontSize = 11;
ax.FontName = 'SansSerif';
fig = gcf;
if ~exist('fullscreen')
    fullscreen = true;
end
sz = [6.5, 3.75];
if ~fullscreen
    sz = sz/2;
end
fig.Units = 'Inches';
fig.Position = [0, 0, sz];
fig.PaperUnits = 'Inches';
fig.PaperSize = sz;
ax.XTick = scale(ax.XLim);
% ax.YTick = scale(ax.YLim);
ax.XLim = [ax.XTick(1),ax.XTick(end)];
% ax.YLim = [ax.YTick(1),ax.YTick(end)];

function out = scale(in)
sig = sigfigs(in)+2;
out = round(in,sig,'significant');
out = [out(1),mean(out),out(end)];
end

function out = sigfigs(in)
top = floor(log(abs(max(in)))/log(10));
df = diff([min(in),max(in)]);
bottom = floor(log(df)/log(10));
out = top - bottom + 1;
end