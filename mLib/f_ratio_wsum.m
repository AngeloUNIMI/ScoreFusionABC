function [fratio, param_com] = f_ratio_wsum(chosen, param, alpha)
%
% [fratio] = f_ratio_wsum(param)
% This function calculates the F-ratio of fusion using weights alpha
% see also : f_ratio, cal_mu, cal_sigma
%

[mu_C, mu_I] = cal_mu(chosen, param, alpha);
[sigma_C, sigma_I, var_C_AV, var_I_AV, var_C_COV, var_I_COV] = cal_sigma(chosen, param, alpha);

fratio = (mu_C - mu_I) ./ (sigma_C + sigma_I);

if (nargout > 1),
    %output to param_com
    param_com.mu_C = mu_C;
    param_com.mu_I= mu_I;
    param_com.sigma_C = sigma_C;
    param_com.sigma_I= sigma_I;
    param_com.var_C_AV = var_C_AV;
    param_com.var_I_AV = var_I_AV;
    param_com.var_C_COV = var_C_COV;
    param_com.var_I_COV = var_I_COV;
end;