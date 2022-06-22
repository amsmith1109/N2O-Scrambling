function out = gauss(size, mu, sigma)
    X = rand(size);
    out = erfinv(1-2*X)*sigma/2 + mu;
end