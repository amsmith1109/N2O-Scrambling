function out = measureScrambling(sa, ref, rr31, doubles)
    %% Input Definitions
    % sa & ref are the known ratios for the calibration run. These should
    % be a nx3 matrix, where n is the number of calibration runs.
    % ref can be a 1x3 vector
    %
    % rr31 is the actual measured isotopic ratio on the IRMS. These
    % are given by the 31r of the sample divided by the 31r of the
    % reference gas.
    %
    %% sensitivity
    % This was added to account for an adjustment to the known 15R values
    % after it found that the spike also increase R46.
    if ~exist('doubles')
        doubles = sa;
    end
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
    %
    % Below is a correction to I31 that includes double substituted
    % species. This is separated from the I31 signal since calibration gas
    % is spiked with single substituted 15Nb. Therefore the double
    % substituted species should be identical to the reference gas.
    % The commented out errorFunction is the calculation without the
    % double substitution correction.
%     errorFunction = @(s) I31(sa, s)./I30(sa, s).*I30(ref, s)./I31(ref, s) - rr31;
    I31doubles = @(R,s) (s*R(1)+(1-s)*R(2))*R(3) + R(1)*R(2);
    errorFunction = @(s) ...
        (I31(sa, s) + I31doubles(doubles, s))./I30(sa, s).*... %31r sample
        I30(ref, s)./(I31(ref, s) + I31doubles(ref,s))... %31r reference
        - rr31; %measured 31r_sa/31r_ref
    out = fzero(errorFunction, [0,.5]);
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