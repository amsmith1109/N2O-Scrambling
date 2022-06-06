clear all;
load('REU data.mat')
for i = 1:numel(N2O)
    N2O{i}.sample = cellfun(@double,N2O{i}.sample);
    N2O{i}.reference = cellfun(@double,N2O{i}.reference);
    N2O{i}.refID = 'praxair';
    N2O_data{i} = IsoData(N2O{i});
    
    NO{i}.sample = cellfun(@double,NO{i}.sample);
    NO{i}.reference = cellfun(@double,NO{i}.reference);
    NO{i}.refID = 'praxair';
    NO_data{i} = IsoData(NO{i});
    
end

REU.NO = NO_data;
REU.N2O = N2O_data;
fname = 'C:/Users/Alex/Documents/GitHub/N2O-Scrambling/Matlab Scripts/REU';
save(fname, 'REU')