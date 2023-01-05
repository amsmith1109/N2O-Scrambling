classdef N2O_calibration_gas
    %% Properties
    properties
        creationDate = datetime;
        delta45 = [];
        delta46 = [];
        delta31 = [];
    end
    properties (Dependent)
        R31
        R45
        R46
        R15a
        R15b
        R17
        R18
    end
    properties (Hidden)
        %% Values commonly used for calculating that don't need to be displayed
        a
        b
        rref
        R_individual
        permil = char(8240);
%         rref = [0.0040564, 0.0077329, 0.00202151]; %same values but from Rolfe's "Ref Tank Calculations" spreadsheet
        %% error terms
        sig45 = [];
        sig46 = [];
        sig31 = [];
    end
    %% Methods
    methods
        function obj = N2O_calibration_gas(d31, d45, d46)
            obj.delta31 = d31;
            obj.delta45 = d45;
            obj.delta46 = d46;
        end
        
        % All methods are for calculating the dependent properties. Since a
        % tank has reported values in delta's, this converts them into the
        % absolute ratios based on N2-Air & VSMOW from rref
        function out = get.R_individual(obj)
            % output = 1x4 vector with individual isotopic ratios
            % output = [R(N-alpha), R(N-beta), R(O17), R(O18)
            %
            % initialize output since it is not calculated in order
            out = zeros(1,4); 
            a = obj.a; 
            b = obj.b;
            %Calculate individual ratios based on available information
            % R31 = N-alpha + O17
            % R45 = N-alpha + N-beta + O17
            % R46 = (N-alpha + N-beta)*O17 + N-alpha*N-beta + O18
            % O17 = a*x^b (a and b defined above)
            beta = obj.R45 - obj.R31; %N-beta is easily the most straight-forward
            alpha = @(x) obj.R45 - beta - x; %Alpha still depends on O17
            O18 = @(x) ((1/a)*x)^(1/b); %O18 will depends on determination of O17
            % O17_root is R46(O17) - R46[known]. The root find is a simple
            % way to calculate it with the tricky non-linearity
            O17_root = @(x) obj.R46...
                        -alpha(x)*x...
                        -beta*x...
                        -alpha(x)*beta...
                        -O18(x);
            O17 = fzero(O17_root,[0,1]);
            % Assign outputs
            out(1) = alpha(O17);
            out(2) = beta;
            out(3) = O17;
            out(4) = O18(O17);
        end
        function out = R_individual_error(obj)
            out = zeros(1,4);
            %% Breaking these out just for clarity
            Rs = obj.R_individual;
            R15a = Rs(1);
            R15b = Rs(2);
            R17 = Rs(3);
            R18 = Rs(4);
            sig31 = obj.sig31*obj.rref(1)/1000;
            sig45 = obj.sig45*obj.rref(2)/1000;
            sig46 = obj.sig46*obj.rref(3)/1000;
            %% Defining the parts of R17 error propagation
            A = @(R17,R31,R45,sig17,sig31,sig45)...
                (R31 - R17)*(R45 - R31)*...
                sqrt((sig31^2 + sig17^2)/(R31 - R17)^2 + ...
                (sig45^2 + sig31^2)/(R45 - R31)^2);
            B = @(R17,R45,sig17,sig45)...
                (R45 - R17)*R17*...
                sqrt((sig45^2+sig17^2)/(R45-R17)^2+...
                sig17^2/R17^2);
            C = @(R17,sig17)...
                (1/obj.b)*...
                ((1/obj.a)*...
                R17)^(1/.516-1)*sig17;
            R31 = (obj.delta31/1000 + 1)*obj.rref(1);
            R45 = (obj.delta45/1000 + 1)*obj.rref(2);
            R46 = (obj.delta46/1000 + 1)*obj.rref(3);
            d17 = @(x) sqrt(A(R17, R31, R45, x, sig31, sig45)^2 + ...
                B(R17, R45, x, sig45)^2+...
                C(R17, x)^2)...
                - sig46;
            sig15b = sqrt(sig45^2 + sig31^2);
            sig17 = fzero(d17,[0,1]);
            sig15a = sqrt(sig31^2 + sig17^2);
            sig18 = obj.b^-1*R17^(1/obj.b-1)/obj.a^(1/obj.b)*sig17;
            out(1) = sig15a;
            out(2) = sig15b;
            out(3) = sig17;
            out(4) = sig18;
        end
        %% Convert stored delta to R
        function out = get.R31(obj)
            out = (obj.delta31/1000+1)*obj.rref(1);
        end
        function out = get.R45(obj)
            out = (obj.delta45/1000+1)*obj.rref(2);
        end
        function out = get.R46(obj)
            out = (obj.delta46/1000+1)*obj.rref(3);
        end
        
        function out = get.R15a(obj)
            out = obj.R_individual(1);
        end
        function out = get.R15b(obj)
            out = obj.R_individual(2);
        end
        function out = get.R17(obj)
            out = obj.R_individual(3);
        end
        function out = get.R18(obj)
            out = obj.R_individual(4);
        end
        function out = get.rref(obj)
        %"natural" 31R, 45R, 46R from N2-air & VSMOW
            out = [0.0040564,... %31R
                   0.0077329,... %45R
                   0.002021510056950];   %46R
        end
        function out = get.a(obj)
            out = 0.00937035;
        end
        function out = get.b(obj)
            out = 0.516;
        end
    end
end