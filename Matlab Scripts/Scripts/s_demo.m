% Unpublished Result
%
% This script was used to demo the shortcoming of determining s from
% comparing the isotopic ratios 31R and 45R. The result is not linear and
% should not be used for determining s.
%
% Please note that Kaiser et al 2004 compare delta-31 vs delta-45/6. These
% plots are linear.

clear all; close all; clc;
load praxair
x = linspace(.1,10);
x = x.';
ss = linspace(.025,.45,8);
for i = ss
s = .5;
s = i;
subplot(4,2,find(i==ss))
R = [praxair.R15a,praxair.R15b,praxair.R17]; %use [0.003681035662880   0.003647256988516   0.000400951832725] if praxair fails to load

% Enhance Alpha
f = R.*ones(100,3);
f(:,1) = f(:,1).*x;
y = expected31R(f, R, s)*praxair.R31;
xx = sum(f(:,1:3),2);
plot(xx,y)
ft = polyfit(xx,y,1);
hold on

%Enhance Beta
f = [R].*ones(100,3);
f(:,2) = f(:,2).*x;
y = expected31R(f, R, s)*praxair.R31;
xx = sum(f(:,1:3),2);
plot(xx,y)
ft2 = polyfit(xx,y,1);

xlabel('{}^{45}R')
ylabel('{}^{31}R_{measured}')
fxAlpha = ['\newline',num2str(ft(1)),'\times x + ',num2str(ft(2))];
fxBeta = ['\newline',num2str(ft2(1)),'\times x + ',num2str(ft2(2))];
legend(['Enhanced {}^{15}N_\alpha',fxAlpha],['Enhanced {}^{15}N_\beta',fxBeta],'Location','NorthWest')

title(['s = ',num2str(s),', From \alpha \rightarrow ',num2str(1-ft(1)),', From \beta \rightarrow ',num2str(ft2(1))])
end
function out = expected31R(sa,ref,s)
    I30 = @(R, s) 1 + s*R(:,1) + (1-s)*R(:,2);
    I31 = @(R, s) (1-s)*R(:,1) + s*R(:,2) + R(:,3);
    out = (I31(sa,s)./I30(sa,s)).*(I30(ref,s)./I31(ref,s));
end