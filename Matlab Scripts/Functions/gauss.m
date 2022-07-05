% simple function for getting random numbers that follow a gaussian
% distribution.
function out = gauss(size, mu, sigma)
    X = rand(size);
    out = erfinv(1-2*X)*sigma/2 + mu;
end