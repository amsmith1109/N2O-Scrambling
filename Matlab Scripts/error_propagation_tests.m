clear all; close all; clc;
load praxair

%% Initialize Inputs
sz = 1e4; % Number of samples

% Using reference gas values as mean values to evaluate error propagation.
s = 0.08;

% R31 Convert to the measured equivalent with an assumed scrambling coefficient.
R31 = praxair.R15a*(1 - s)...
    + praxair.R15b*s...
    + praxair.R17; 
R45 = praxair.R45;
R46 = praxair.R46;
y = [R31, R45, R46];

%% Evaluate influence of error due to scrambling coefficient
if 1
    ds = s*.05; % Corresponds to 5% error in s
    
    % Create random error measurements
    sIN = gauss([1,sz], s, ds);
    % Loop to calculate individual values based on random error in s
    output = zeros(sz, 4);
    for i = 1:sz
        output(i,:) = rMeasure(y, sIN(i));
    end
    
    % Calculate site-preference and associated error
    sp = (output(:,1) - output(:,2));
    [fts, errsp] = gaussFit(sp);
    disp(['Histogram fit results yield ', num2str(errsp), '% error ',...
        'resulting from 5% error in s.'])
    disp(['Direct calculation of standard deviation and mean value yield ',...
        num2str(std(sp)/mean(sp)*100), '%'])
    histogram(sp)
    hold on
    plot(fts)
    
end

%% Influence of error in double substituted species
% This tests demonstrates the little influence of R31 and R45 on the
% determination of R18.
%
% Suppose relative error of 1% for R46, 50% for R31 and R45. If uncertainty 
% is primarily determined by the R46 measurement, the ending uncertainty
% should be close to 1% for R18.
if true
sig = [y(1)*0.5, y(2)*0.5, y(3)*.01]; 
Y = zeros([sz,3]);
output = zeros([sz,4]);
for i = 1:3
     Y(:,i) = gauss([sz,1], y(i), sig(i));
end
for i = 1:sz
    output(i,:) = rMeasure(Y(i,:), s);
end
R18 = output(:,4);
[ft18, err18] = gaussFit(R18);
disp(['Histogram fit results yield ', num2str(err18), '% error ',...
    'resulting from 1% error in R46.'])
figure
histogram(R18)
hold on
plot(ft18)
end    