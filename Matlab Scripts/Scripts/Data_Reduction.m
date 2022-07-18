%% Set up workspace
clear all; clc; close all;
load N2O
load NO
load energy %varying energy data for 4 samples
load praxair


%% N2O Data reduction
% results are a table with the following:
% Sample name, R15a, R15b, R17, R15b_doubles
names = fields(N2O);
n = numel(names);
N2O_data_table = cell(n,5);
for i = 1:n
    r = [];
    for j = 1:numel(N2O.(names{i}))
        r(j,1) = N2O.(names{i}){j}.R(1);
        r(j,2) = N2O.(names{i}){j}.R(2);
    end
    r = mean(r,1);
    sampleR15b = (r(1) - praxair.R45) + praxair.R15b;
    R46_added = r(2) - praxair.R18 - praxair.R17*praxair.R15a;
    R15b_double = R46_added/(praxair.R17 + praxair.R15a);
    N2O_data_table{i,1} = names{i};
    N2O_data_table{i,2} = praxair.R15a;
    N2O_data_table{i,3} = sampleR15b;
    N2O_data_table{i,4} = praxair.R17;
    N2O_data_table{i,5} = R15b_double;
    N2O_data.(names{i}) = [praxair.R15a,...
                        sampleR15b,...
                        praxair.R17,...
                        R15b_double];
end
N2O_data_table = cell2table(N2O_data_table);
N2O_data_table.Properties.VariableNames = {'Sample_name' , 'R15a', 'R15b' , 'R17' , 'R15b_doubles'};
[~,idx] = sort(N2O_data_table.R15b);
N2O_data_table = N2O_data_table(idx,:);
names = {names{idx}};
%save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data_table.mat','N2O_data_table')
%save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data.mat','N2O_data')

%% NO Data Reduction
NO_data = [];
for i = 1:n
    set = NO.(names{i});
    for j = 1:numel(set)
        intensity = mean(set{j}.sample(:,1));
        r = set{j}.r(1); 
        NO_data(end+1,:) = [i, intensity, r];
    end
end
NO_data = array2table(NO_data);
NO_data.Properties.VariableNames = {'Sample_name' , 'Intensity_mV', 'rr31'};
NO_data.Sample_name = {names{[NO_data.Sample_name]}}.';
%save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO.mat','NO_data')

%% Energy NO Data Reduction
experiments = fields(energy);
for i = 1:4
    set = energy.(experiments{i});
	names = fields(set);
    data = [];
    for j = 1:numel(names)
        subset = set.(names{j});
        for k = 1:numel(subset)
            intensity = mean(subset{k}.sample(:,1));
            r = subset{k}.r(1); 
            data(end+1,:) = [j, intensity, r];
        end
        1;
    end
    NO_energy_data.(experiments{i}) = array2table(data);
    NO_energy_data.(experiments{i}).Properties.VariableNames = {'Sample_name' , 'Intensity_mV', 'rr31'};
    NO_energy_data.(experiments{i}).Sample_name = {names{[NO_energy_data.(experiments{i}).Sample_name]}}.';
end

%save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO_energy.mat','NO_energy_data')
