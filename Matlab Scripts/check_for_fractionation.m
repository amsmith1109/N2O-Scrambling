% check_for_fractionation
%
% This script looked at the NO measurements for each sample and compared
% the first time 31R was measured versus the 2nd time it was measured in a
% sample run. If fractionation did occur, it would always be lower/higher
% during the second run. If it was insignificant, it would bounce between
% positive and negative differences.
%
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 24-Jan-2023
close all; clear all; clc;
load NO

names = fields(NO);
deltas = [];
rr = [];
RR = [];
% Loop through each sample
for i = 1:numel(names)
    r = []; % placeholder for measured 31r
    in = []; % placeholder for averaged intensity
    % Loop through each measurement
    for j = 1:numel(NO.(names{i}))
        r(end+1) = NO.(names{i}){j}.r(2);
        in(end+1) = mean(NO.(names{i}){j}.sample(:,1));
    end
    
    % reshape ensures the results are column vectors
    r = reshape(r,[],1);
    in = reshape(in,[],1);
    idx = find(diff(in)>100); % identify when the sequences restarts
    try
        r_mat = [r(1:7), r(8:14);...
            r(15:22), r(23:30)];
    catch
        switch names{i}
            % The cases below didn't use the same scheme as described in
            % the paper. Some of these used increasing signal intensity to
            % help identify if there is a systematic error caused by always
            % measuring with decreasing signal intensity.
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
    % Store the results:
    % dr = difference between 1st and 2nd measurement at the same intensity
    deltas = [deltas ; r_mat(:,1) - r_mat(:,2)];
end
% Results suggest little bias between first and second measurement.
histogram(deltas)