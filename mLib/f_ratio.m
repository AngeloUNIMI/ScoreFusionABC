function [fratio] = f_ratio(param)

% [fratio] = f_ratio(param)
% This function calculates the F-ratio of base-expert(s)
fratio = (param.mu_C - param.mu_I) ./ (param.sigma_C + param.sigma_I);