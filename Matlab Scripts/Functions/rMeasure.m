function out = rMeasure(R31, R45, R46, s)
    a = 0.00937035;
    b = 0.516;
    R18 = @(R17) ((1/a)*R17)^(1/b);
    
    R15a = @(R17) ...
        (1 / (1 - 2*s))*...
        (R31 - s*R45 - (1-s)*R17);
    
    R15b = @(R17)...
        (1 / (1 - 2*s))*...
        ((1-s)*R45 - R31 + s*R17);
    
    err_function = @(R17) R46... %R46 - all below
        - R15a(R17) * R15b(R17)...  %15N15N16O
        - R15a(R17) * R17...        %14N15N17O
        - R15b(R17) * R17...        %15N14N17O
        - R18(R17);                %14N14N18O
    
    R17 = fzero(err_function, [0,1]);
    
    out = [R15a(R17),...
        R15b(R17),...
        R17,...
        R18(R17)];
end