clear all; close all; clc;
load NO
load praxair
names = fields(NO);
for i = 1:numel(names)
    for j = 1:numel(NO.(names{i}))
        NO.(names{i}){j}.AMU = [30,31,32];
        
        
%         sa = [[data.sample{:,1}].',[data.sample{:,2}].',[data.sample{:,3}].'];
%         ref = [[data.reference{:,1}].',[data.reference{:,2}].',[data.reference{:,3}].'];
%         obj = IsoData;
%         obj.sample = sa;
%         obj.reference = ref;
%         D.(names{i}){j} = obj;
    end
end

clearvars -except NO