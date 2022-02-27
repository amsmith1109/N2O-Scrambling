function [I,d,dW] = calcSetR(set)
    R = [];
    I = [];
    for j = 1:numel(set)
        data = set{j};
        [R(j) W(j)] = Ratio(data,2);
        I(j) = intensity(data);
    end
    [I idx] = sort(I);
    R = R(idx);
    W = W(idx);
    j = 1;
    x = [];
    y = [];
    while j<numel(I)
        if I(j+1)-I(j)<150
            % average and replace two neighboring values
            I(j) = mean(I(j:j+1));
            R(j) = mean(R(j:j+1));
            W(j) = sqrt(W(j)^2+W(j+1)^2);
            % kick the 2nd value to compress the vector
            I(j+1) = [];
            R(j+1) = [];
            W(j+1) = [];
            % otherwise, proceed to the next index
        else
            j = j+1;
        end
    end
    d = (R/refR-1)*1000;
    dW = 2*1.95*W*1000/refR;
end