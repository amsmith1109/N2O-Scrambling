% IsoData is an object container for processing raw dual-inlet measurements.
%
%% Description of Properties:
% sample & reference are raw voltage measurements from IRMS measurements.
%
% refID is a text tag to identify which reference gas was used. This is
% necessary to obtain the true R ratios relative to VSMOW & N2 air. 
% 
% AMU is a matrix that identifies the mass that corresponds to each
% measurement. This is necessary for pulling in the appropriate information
% of the reference gas.
%
% rref are the isotopic ratios of the reference gas. This is a dependent
% variable as it depends on refID tag.
% 
% Please note that this object definition is designed for N2O, but can be
% expanded to other types of gases. 
%% Description of Methods:
% IsoData
% 
% r: calculates the intensity ratio based on the index called.
%
% R: calculates the isotopic ratio based on the intensity ratio r, and the
% known isotopic composition of the reference gas.
%
% delta: calculates the isotopic compositions deviation from the accepted
% international standard. Depends on R and hidden properties in the
% reference gas.
%% Code:
classdef IsoData
    properties
        sample double {mustBeReal, mustBeFinite}
        reference double {mustBeReal, mustBeFinite}
        refID = 'praxair';
        AMU(3,1) int32 {mustBeReal, mustBeFinite}
    end
    properties (Dependent)
        rref
    end
    
    methods
        % Initialization function. Converts a struct to the IsoData class
        % Or accepts individual inputs for each property
        function obj = IsoData(samp, ref, ID, AMU)
            if nargin==1
                if isstruct(samp)
                    obj.sample = samp.sample;
                    obj.reference = samp.reference;
                    obj.refID = samp.refID;
                    obj.AMU = samp.AMU;
                end
            elseif nargin==4
                obj.sample = samp;
                obj.reference = ref;
                obj.refID = ID;
                obj.AMU = AMU;
            end
            if size(obj.sample, 1) ~= size(obj.reference, 1) - 1
                error('There must be one more reference measurements than sample measurements.')
            end
            try
                load(obj.refID);
            catch
                error(['Reference ID "',...
                    obj.refID,...
                    '" does not exist. Please create it ',...
                    'before initializing IsoData variable.'])
            end
        end
        
        % r() calculates the intensity ratios. 
        % idx specifies the reference isotologue (typically 1)
        function [out, error] = r(obj, idx)
            if nargin==1
                idx = 1;
            end
            I_sa = obj.sample(:,idx+1) ./ obj.sample(:,1);
            I_ref = refR(obj, idx);
            out = mean(I_sa ./ I_ref); %measurement
            error = std(I_sa ./ I_ref) / sqrt(numel(I_sa)); %standard error
        end
        
        function [out, error] = refr(obj, idx)
            if nargin==1
                idx = 1;
            end
            
        end
        
        % R() calculates the actual ratio of isotopologues (e.g. 15N/14N)
        % Note that this does not account for scrambling!
        function [out, error] = R(obj, idx)
            ref = obj.rref;
            [r, error] = obj.r(idx);
            out = r * ref(idx + 1);
            error = error * ref(idx + 1);
        end
        
        % rref() returns the isotopologue ratio of the reference gas.
        % This requires loading in calibration data of the reference gas.
        function out = get.rref(obj)
            ref = load(obj.refID);
            ref = ref.(obj.refID);
            switch obj.AMU(1)
                case 30
                    out = [1 ref.R31, 0]; 
                    %32 AMU is set to zero since the measurements 
                    % are too unreliable.
                case 44
                    out = [1, ref.R45, ref.R46];
            end
        end
        
        % delta() returns the permil deviation of the sample relative to
        % the accepted international standard. For N2O, this corresponds to
        % stochastically made N2O from N2-air and VSMOW.
        function out = delta(obj, idx)
            ref = load(obj.refID);
            ref = ref.(obj.refID);
            amu = obj.AMU(idx+1);
            switch amu
                case 31
                    id = 1;
                case 45
                    id = 2;
                case 46
                    id = 3;
            end
            r_ref = ref.rref(id);
            r_sa = obj.R(idx);
            out(1) = (r_sa(1) / r_ref - 1) * 1000;
            %out(2) = abs(1000/r_ref)*r_sa(2);
        end
       
    end
end
%% Functions shared with the object definition
% refR() returns an average r value for for the reference gas.
% This is done because the reference is measured before and after
% any sample gas is measured. The average is supposed to correct
% for any detector drift that may occur in the short time between
% measurements. Thus the average is an extrapolation that estimates
% how the reference would've been measured at the time the sample
% was measured.
function out = refR(obj,idx)
    top = conv(obj.reference(:,idx+1), [.5 .5], 'valid');
    bottom = conv(obj.reference(:,1), [.5 .5], 'valid');
    out = top ./ bottom;
end