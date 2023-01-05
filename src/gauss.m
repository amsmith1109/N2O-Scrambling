% Gauss - function for creating gaussian distributed random numbers
% 
% Description:
%   Matlab has the "normrmd" function for this, but it requires the 
%   Statistics and Machine Learning Toolbox. This is a pseudo-random number
%   generator that seeds the inverted cumulative distribution function with
%   uniformly distributed from the matlab "rand" function. This function
%   was created for bootstrapping with the base version of matlab.
%
% Requirements:
%   None
%
% Examples:
%   gauss(1) = single random number
%   gauss(5) = 5x5 matrix of random numbers
%   gauss(1e3, 10, 5) = 1,000 x 1,000 matrix of random numbers that have a
%       mean value of 10 and a standard deviation of 5.
%
% Inputs:
%   size = desired matrix output size. This is identical to the size input
%       for the rand function. A single number results in a square matrix
%       that is n x n. An input of [n, m] results in a matrix of random
%       numbers that is n x m.
%   mu = mean value of distribution
%   sigma = standard deviation
%
%   mu and sigma are not required inputs. They will default to a mean value
%   of 0, with a standard deviation of 1.
% 
% Output:
%   out = matrix of random numbers. A large enough output and a histogram
%   should demonstrate that these follow a normal distribution.
% 
% Author: Alex Smith
% email address: amsmith1109@gmail.com
% Created: July 2022; Last revision: 05-Jan-2023
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