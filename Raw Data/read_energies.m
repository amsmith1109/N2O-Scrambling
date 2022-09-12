clear all; close all; clc;
refs = readtable('Lookup of Sample Runs.csv');
dtable = readtable('All Data.csv');
% Filter for data of interest and reduce the data table to that subset.
idx1 = find(refs.Setting==1);
idx2 = find(refs.Electron_Energy~=124);
idx = intersect(idx1, idx2);

% Configure names for organizing data
samples = {'A2', 'B2', 'C2', 'D2'};
energies = [70, 80, 90, 100, 110, 120];
names = {'NO70', 'NO80', 'NO90', 'NO100', 'NO110', 'NO120'};


ID = 'NO';
AMU = [30, 31, 32];
for i = 1:numel(names)
    for j = 1:numel(samples)
        % Initialize sub-directory
        energy.(names{i}).(samples{j}) = {};
        % index measurements for this experiment + sample
        % from index, find matching energy [i] and matching sample [j]
        eng_idx = find(refs.Electron_Energy==energies(i));
        name_idx = find(contains(refs.Sample_Name,samples{j}));
        pre_idx = intersect(idx, eng_idx);
        data_idx = intersect(pre_idx, name_idx);
        for k = data_idx.'
            % read in data from dtable to data
            rows = find(dtable.idx==k);
            data = table2array(dtable(rows,2:end));
            sample = data(2:end,1:3);
            ref = data(:,4:6);
            energy.(names{i}).(samples{j}){end+1} = IsoData(sample, ref, ID, AMU);
        end
    end
end

clearvars -except energy
save('all_energy.mat')