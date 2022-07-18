close all; clear all; clc;
load NO

names = fields(NO);
deltas = [];
rr = [];
for i = 1:numel(names)
    r = []; % measured 31r
    in = []; % averaged intensity
    for j = 1:numel(NO.(names{i}))
        r(end+1) = NO.(names{i}){j}.r(2);
        in(end+1) = mean(NO.(names{i}){j}.sample(:,1));
    end
    r = reshape(r,[],1);
    in = reshape(in,[],1);
    idx = find(diff(in)>100); % identify when the sequences restarts
    try
        r_mat = [r(1:7), r(8:14);...
            r(15:22), r(23:30)];
    catch
        switch names{i}
            % The cases below didn't use the same scheme as described in
            % the paper.
            case 'C0'
                r_mat = [r(1:4), r(5:8);...
                    r(9:11), r([12,13,15]);...
                    r(15:21), r(21:end)];
            case 'A0'
                r_mat = [r(1:4), r(5:8);...
                    r(9:12), r(13:16);...
                    r(21:24), r(25:end)];
            case 'D0'
                r_mat = [r(1:4), r(5:8);...
                    r(9:12), r(13:16)];
            case 'B0'
                r_mat = [r(1:6), r(7:12);...
                    r(13:16), r(17:20)];
        end
    end
    dr = r_mat(:,1) - r_mat(:,2);
    rr(end+1,:) = [mean(r);mean(dr)];
    deltas = [deltas ; dr];
end