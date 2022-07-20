function out = invRM(in, s, doubles)
    if ~exist('s')
        s = 0;
    end
    if ~exist('doubles')
        doubles = in;
    end
    out(1) = (1-s)*in(1) + s*in(2) + in(3); %R31
    out(2) = sum(in(1:3)); %R45
    out(3) = in(4)...
        + doubles(1)*doubles(2)...
        + doubles(2)*doubles(3)...
        + doubles(1)*doubles(3);
end