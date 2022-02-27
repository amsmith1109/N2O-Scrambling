function [R err] = Ratio(in,idx)
    if ~exist('idx')
        idx = 2;
    end
    base = find(in.rref==1);
    ref = in.reference(:,idx);
    baseref = in.reference(:,base);
    sa = in.sample(:,idx);
    basesa = in.sample(:,base);
    ref = conv(ref,[.5 .5],'valid');
    baseref = conv(baseref,[.5 .5],'valid');
    rref = ref./baseref;
    rsa = sa./basesa;
    R = mean(rsa./rref)*in.rref(idx);
    err = std(rsa./rref)*in.rref(idx);
end