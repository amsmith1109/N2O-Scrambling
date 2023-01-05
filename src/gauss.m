% Simple function for getting random numbers that follow a gaussian
% distribution.
function out = gauss(size, mu, sigma)
    if ~exist('mu')
        mu = 0;
    end
    if ~exist('sigma')
        sigma = 1;
    end
    X = rand(size);
    out = erfinv(1-2*X)*sigma/2 + mu;
end