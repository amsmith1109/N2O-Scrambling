%% Set up workspace
clear all; clc; close all;
load N2O
load NO
load energy %varying energy data for 4 samples
load praxair
runN2O = 1;
runNO = 0;
runEng = 0;

names = fields(N2O);
n = numel(names);
%% N2O Data reduction
% results are a table with the following:
% Sample name, R15a, R15b, R17, R15b_doubles
if runN2O
N2O_data_table = cell(n,5);
for i = 1:n
    r = [];
    for j = 1:numel(N2O.(names{i}))
        r(j, 1) = N2O.(names{i}){j}.R(1);
        r(j, 2) = N2O.(names{i}){j}.R(2);
    end
    r = mean(r,1);
    
    R45_added = r(1) - praxair.R45;
    R46_added = r(2) - praxair.R46;
    sampleR15b = R45_added + praxair.R15b;
    %% Double Substitutions
    R15ab = praxair.R15a*praxair.R15b + 10/11*R46_added;
    R15ao = praxair.R15a*praxair.R17;
    R15bo = praxair.R15b*praxair.R17 + 1/11*R46_added;

    %% Assign results
    N2O_data_table{i,1} = names{i};
    N2O_data_table{i,2} = praxair.R15a;
    N2O_data_table{i,3} = sampleR15b;
    N2O_data_table{i,4} = praxair.R17;
    N2O_data_table{i,5} = R15ab;
    N2O_data_table{i,6} = R15ao;
    N2O_data_table{i,7} = R15bo;
    N2O_data.(names{i}) = [praxair.R15a,...
                        sampleR15b,...
                        praxair.R17,...
                        R15ab,...
                        R15ao,...
                        R15bo];
end
N2O_data_table = cell2table(N2O_data_table);
N2O_data_table.Properties.VariableNames = {'Sample_name' , 'R15a', 'R15b' , 'R17' ,...
                                        'R15a_doubles', 'R15b_doubles', 'R17_doubles'};
[~,idx] = sort(N2O_data_table.R15b);
N2O_data_table = N2O_data_table(idx,:);
names = {names{idx}};
save('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data_table.mat','N2O_data_table')
save('E:\My Documents\School\github\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data.mat','N2O_data')
% save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data_table.mat','N2O_data_table')
% save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\N2O_data.mat','N2O_data')
end

%% NO Data Reduction
if runNO
NO_data_matrix = [];
for i = 1:n
    set = NO.(names{i});
    NO_data.(names{i}) = [];
    for j = 1:numel(set)
        intensity = mean(set{j}.sample(:,1));
        r = set{j}.r(1); 
        NO_data_matrix(end+1,:) = [i, intensity, r];
        NO_data.(names{i})(end+1,:) = [intensity, r];

    end
end
NO_data_table = array2table(NO_data_matrix);
NO_data_table.Properties.VariableNames = {'Sample_name' , 'Intensity_mV', 'rr31'};
NO_data_table.Sample_name = {names{[NO_data_table.Sample_name]}}.';
% save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO_data.mat','NO_data')
% save('C:\Users\Alex\Documents\GitHub\N2O-Scrambling\Matlab Scripts\Data\Reduced Data\NO_data_table.mat','NO_data_table')
end

%% Energy NO Data Reduction
if runEng
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
end


function out = dbl(R46, ref)
    k = ref.R17/ref.R15a;
    R15a_add = @(b) b/(1+k);
    R17_add = @(b) k*R15a_add(b);
    
end