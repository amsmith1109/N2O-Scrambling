%% Description:
%   measureScrambling - determine scrambling coefficient from measurements
%
%   Function that computes the scrambling coefficient from a given set of
%   measurements. This uses the root-finding method to determine the
%   scrambling coefficient that explains the measured values for known
%   isotopic ratios of the sample and reference gas. Additional inputs are
%   available for double substituted species. This was added as it was
%   found the the definitions of individual isotopic ratios do not always
%   agree when considering double substitutions.
%
%   The doubles substitution correction can be used in different ways. If 
%   no correction is provided for the double substituted species are
%   assumed to be zero. Using a simple "true" input will cause the double
%   substituted species to be calculated from the individual isotopic 
%   ratios (i.e., N15_alpha, N15_beta, O17 and O18).
%
%   This function can return a vector output if a matrix of measurement
%   values are given. However, it is restricted to a single gas as it
%   expects a single line that describes that known ratios of the sample
%   and reference gas.
%
%% Example:
%   Single input, no doubles correction:
%    measureScrambling([0.0037    0.0041    0.0004    0.0021],...
%                      [0.0037    0.0037    0.0004    0.0021],...
%                      1.0089)
%       = 0.95
%
%   Multiple inputs, no doubles correction:
%    measureScrambling([0.0037    0.0041    0.0004    0.0021],...
%                      [0.0037    0.0037    0.0004    0.0021],...
%                      [1.00894, 1.00892, 1.00891])
%       = [0.0953, 0.0951, 0.0950]
%
%   Single input, doubles correction:
%    measureScrambling([0.0037    0.0041    0.0004    0.0021],...
%                      [0.0037    0.0037    0.0004    0.0021],...
%                      1.0089,...
%                      1e-4*[0.1541    0.0143    0.0161])
%       = 0.908
%
%   Single input, doubles assumed normal:
%    measureScrambling([0.0037    0.0041    0.0004    0.0021],...
%                      [0.0037    0.0037    0.0004    0.0021],...
%                      1.0089,	1)
%       = 0.913
%
%% Requirements:
%   None
%
%% Inputs:
%   sa = [N15_alpha, N15_beta, O17, O18] of sample gas
%   ref = [N15_alpha, N15_beta, O17, O18] of reference gas
%   rr31 = IRMS measured ratio ([U31/U30]_sa / [U31/U30]_ref)
%   doubles = [N15_alpha x N15_beta,...
%              N15_alpha x O17,...
%              N15_beta x O17]
%       doubles is for the double substituted isotopomers that give a 46R
%       signal. 
%
%% Outputs:
%   out = scrambling coefficients that explains measurement for the
%       measured signal intensity ratio(s).
%
%% Authorship:
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 05-Jan-2022
%% Function:
function out = measureScrambling(sa, ref, rr31, doubles)
    if ~exist('doubles')
        doubles = [0, 0, 0];
        ref_dbl = [0, 0, 0];
    else
        % doubles can be 0,1 indicating to use the other inputs, if it is a
        % 1x3, it will use them for the doubles calculation.
        if doubles == 1
            doubles = calcDouble(sa);
        elseif doubles == 0
            doubles = calcDoubles(ref);
        end
        % calculate the corresponding doubles for the reference.
        ref_dbl = calcDouble(ref);
    end
    n = numel(rr31);
    %
    %% Functional definitions
    % Ixx represent the ion current for the xx AMU measurement in terms of isotope ratios
    %
    % R is a 3x1 vector with known ratio inputs
    % R(1) = alpha, R(2) = beta, R(3) = 17O
    %
    % r is the measured ratio of sample ratio to reference ratio
    % Sensitivity is added as a way to check variability of the scrambling
    % coefficient if it is different for 15Na and 15Nb.
    I30 = @(R, s) 1 + s*R(1) + (1-s)*R(2);
    I31 = @(R, s) (1-s)*R(1) + s*R(2) + R(3);
    %
    % Doubles consider the double-substitutions that contribute to the 31R
    % signal. The terms used here are the ratios of the double substituted
    % gas to 44-N2O.
    % R(1) = alpha*beta, R(2) = alpha*17O, R(3) = beta*17O
    I31doubles = @(R,s) R(1) + s*R(2) + (1-s)*R(3);
%     I31doubles = @(R,s) R(1)*R(2) + s*R(1)*R(3) + (1-s)*R(2)*R(3);
%     ref_dbl = ref;
%     doubles = ref;
    %
    %
    % Below is a correction to I31 that includes double substituted
    % species. This is separated from the I31 signal since calibration gas
    % is spiked with single substituted 15Nb. Therefore the double
    % substituted species should be identical to the reference gas.
    % The commented out errorFunction is the calculation without the
    % double substitution correction.
    for i = 1:n
        errorFunction = @(s) ...
            (I31(sa, s) + I31doubles(doubles, s))./(I30(sa, s) + doubles(1)*.9).*... %31r sample
            (I30(ref, s) + ref_dbl(1)*.9)./(I31(ref, s) + I31doubles(ref_dbl, s))... %31r reference
            - rr31(i); %measured 31r_sa/31r_ref
        out(i) = fzero(errorFunction, [0,1]);
    end
    % Below is code that calculates the scrambling using the generally
    % used method for obtaining the measured ratios. Where:
    % R = r_sa/r_ref x R_ref
    % This was only used for comparison to see if considering scrambling in
    % the reference measurement is significant. Which yes it is!
    % 
%     erf2 = @(s) I31(sa, s) - rr31*0.004081987495605;
%     out(2) = fzero(erf2, [0,.5]);
    out = out.';
end

    % calcDoubles determines the double-substituted ratios from the
    % singles.
    % R(1) = alpha*beta, R(2) = alpha*17O, R(3) = beta*17O    
    function out = calcDouble(in)
        out = [in(1)*in(2),...
               in(1)*in(3),...
               in(2)*in(3)];
    end
        
