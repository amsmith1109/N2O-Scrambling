clear all; close all; clc;
folder = 'C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Figures\sensitivity test\';
directory = dir([folder,'*.fig']);
fname = {directory.name};
for i = 1:14
    file = [folder,fname{i}];
    openfig(file, 'visible')
    ax = gca;
    lgd = strrep(ax.Legend.String{1}, '\cdot I', '\cdot U_{30}');
    ax.Legend.String{1} = lgd;
    savefig(file);
    file = strrep(file, '.fig', '.png');
    saveas(gcf, file);
    close all
end