% rMeasure - Computes 15R_alpha, 15R_beta, 17R, 18R from IRMS results
%
% Description:
%   Calculates individual N and O ratios using the formulation of 
%   R31_measured, R45, and R46 from Kaiser et al 2003 along with the 
%   mass-dependent fractionation of oxygen. Fractionation constants a & b
%   are defined at the beginning of the function. Due to the non-linearity
%   of the mass-dependent fractionation, 18R has to be calculated using a
%   root-finding approach. All other ratios are then simple substitutions.
%   See Kaiser et al (2003)  https://doi.org/10.1029/2003JD003613
%
% Example: 
%    rMeasure([0.0041, 0.0078, 0.0021], 0.08)
%       = [0.0037    0.0037    0.0004    0.0021]
%
% Requirements:
%   None
%
% Inputs:
%   R31 = Measured m/z 31 ratio
%   R45 = Measured m/z 45 ratio
%   R46 = Measured m/z 46 ratio
%   s = scrambling coefficient
%
% Outputs:
%   out = [R15_alpha,   R15_beta,   R17,    R18]
%
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 05-Dec-2022
function out = rMeasure(R, s)
    % Oxygen Fractionation Constants
    a = 0.00937035;
    b = 0.516;
    % Explicit definitions from the vector
    R31 = R(1);
    R45 = R(2);
    R46 = R(3);
    if ~exist('s')
        s = 0;
    end
    R17 = @(R18) a * R18^b;
    
    R15a = @(R18) ...
        (1 / (1 - 2*s))*...
        (R31 - s*R45 - (1-s)*R17(R18));
    
    R15b = @(R18)...
        (1 / (1 - 2*s))*...
        ((1-s)*R45 - R31 + s*R17(R18));
    
    err_function = @(R18) R46...    %R46 - all below
        - R15a(R18) * R15b(R18)...  %15N15N16O
        - R15a(R18) * R17(R18)...   %14N15N17O
        - R15b(R18) * R17(R18)...   %15N14N17O
        - R18;                      %14N14N18O
    
    R18 = fzero(err_function, [0,1]);
    
    out = [R15a(R18),...
        R15b(R18),...
        R17(R18),...
        R18];
end
