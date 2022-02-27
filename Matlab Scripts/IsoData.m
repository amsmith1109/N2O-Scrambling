classdef IsoData
    properties
        sample(10,3) double {mustBeReal, mustBeFinite}
        reference(11,3) double {mustBeReal, mustBeFinite}
        refID = 'praxair';
        AMU(3,1)
    end
    properties (Dependent)
        rref
    end
    
    methods
        function out = r(obj, idx)
            I_sa = obj.sample(:,idx+1)./obj.sample(:,1);
            I_ref = refR(obj,idx);
            out = mean(I_sa./I_ref); %measurement
            out(2) = std(I_sa./I_ref)/sqrt(numel(I_sa)); %standard error
        end
        function out = R(obj, idx)
            ref = obj.rref;
            r = obj.r(idx);
            out = r*ref(idx+1);
        end
        function out = get.rref(obj)
            ref = load(obj.refID);
            ref = ref.(obj.refID);
            switch obj.AMU(1)
                case 30
                    out = [1 ref.R31, 0]; %32 AMU is set to zero since the measurements are too unreliable.
                case 44
                    out = [1, ref.R45, ref.R46];
            end
        end
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
            out(1) = (r_sa(1)/r_ref-1)*1000;
            out(2) = abs(1000/r_ref)*r_sa(2);
        end
    end
end

function out = refR(obj,idx)
    top = conv(obj.reference(:,idx+1),[.5 .5],'valid');
    bottom = conv(obj.reference(:,1),[.5 .5],'valid');
    out = top./bottom;
end