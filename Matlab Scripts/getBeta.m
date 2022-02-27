function out = getBeta(in)
    r_sample = [in.sample{:,2}]./[in.sample{:,1}];
    r_ref = diff([in.reference{:,2}])/diff([in.reference{:,1}]);
    out = (r_sample/r_ref);
end