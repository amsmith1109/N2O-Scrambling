clear all; close all; clc;
% load energy
% exp = fields(energy);
% names = fields(energy.(exp{1}));
% for k = 1:numel(exp)
%     for i = 1:numel(names)
%         for j = 1:numel(energy.(exp{k}).(names{i}))
%             energy.(exp{k}).(names{i}){j}.AMU = [30, 31, 32];
%             data = energy.(exp{k}).(names{i}){j};
%             sa = double([[data.sample{1:10,1}].',[data.sample{1:10,2}].',[data.sample{1:10,3}].']);
%             ref = double([[data.reference{1:11,1}].',[data.reference{1:11,2}].',[data.reference{1:11,3}].']);
% %             sa = double(data.sample);
% %             ref = double(data.reference);
%             obj = IsoData;
%             obj.sample = sa;
%             obj.reference = ref;
%             D.(exp{k}).(names{i}){j} = obj;
%         end
%     end
% end
% energy = D;
% clearvars -except energy

load data
names = fields(NO);
for k = 1:numel(NO)
    for i = 1:numel(names)
        for j = 1:numel(NO.(names{i}))
            NO.(names{i}){j}.AMU = [30, 31, 32];
            data = NO.(names{i}){j};
            sa = double([[data.sample{1:10,1}].',[data.sample{1:10,2}].',[data.sample{1:10,3}].']);
            ref = double([[data.reference{1:11,1}].',[data.reference{1:11,2}].',[data.reference{1:11,3}].']);
            obj = IsoData;
            obj.sample = sa;
            obj.reference = ref;
            D.(names{i}){j} = obj;
        end
    end
end
NO = D;
clearvars -except NO
save NO

load data
names = fields(N2O);
for k = 1:numel(N2O)
    for i = 1:numel(names)
        for j = 1:numel(N2O.(names{i}))
            N2O.(names{i}){j}.AMU = [30, 31, 32];
            data = N2O.(names{i}){j};
            sa = double([[data.sample{1:10,1}].',[data.sample{1:10,2}].',[data.sample{1:10,3}].']);
            ref = double([[data.reference{1:11,1}].',[data.reference{1:11,2}].',[data.reference{1:11,3}].']);
            obj = IsoData;
            obj.sample = sa;
            obj.reference = ref;
            D.(names{i}){j} = obj;
        end
    end
end
N2O = D;
clearvars -except N2O
save N2O