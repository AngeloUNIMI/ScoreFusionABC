function [var_adj] = VR_Fratio_norm(param, class_sep)
% This function normalises param such that
% the cliet and impostor mean difference is exactly 2
% [var_adj] = VR_Fratio_norm(param)
% returns the parameter that is needed to adjust the variance
% [var_adj] = VR_Fratio_norm(param, class_sep)
% overwrite the default value of class_sep = 2

if (nargin < 2),
    class_sep = 2;
end;
%calculate variance adjustment:
mean_diff = (param.mu_C - param.mu_I  ) ./ param.sigma_all;
var_adj = class_sep ./ mean_diff;

