function out = intensity(in)
    base = find(in.rref==1);
    out = mean([in.reference(:,base)]);
end