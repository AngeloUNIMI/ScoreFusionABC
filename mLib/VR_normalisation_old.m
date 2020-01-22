function [nparam, var_adj] = VR_Fratio_norm(param)
% This function normalises param such that:
% (1) the cliet and impostor mean difference is exactly 2
% and (2) that both client and impostor scores have 
% unit-variance (zero mean and 1 standard deviation)
% 

if (mode == 1),
    %unit variance normalisation only
    var_adj = 1 ./ param.sigma_all;

    nparam.mu_all = param.mu_all .* var_adj;
    nparam.sigma_all = param.sigma_all .* var_adj;
    nparam.mu_I = (param.mu_I - param.mu_all) ./ param.sigma_all .* var_adj;
    nparam.mu_C = (param.mu_C - param.mu_all) ./ param.sigma_all .* var_adj;
    nparam.size_I = param.size_I;
    nparam.size_C = param.size_C;
    %make the adjustments for cov:
    for i=1:size(param.mu_all,2),
      for j=1:size(param.mu_all,2),
        var_adj_cov(i,j) = var_adj(i) * var_adj(j);
      end;
    end;
    t = var_adj_cov;
    nparam.cov_all =  t;
    nparam.cov_C = param.cov_C ./ param.cov_all .* t;
    nparam.cov_I = param.cov_I ./ param.cov_all .* t;
    
end

if (mode == 3),
    %calculate variance adjustment:
    mean_diff = (param.mu_C - param.mu_I  ) ./ param.sigma_all;
    var_adj = 2 ./ mean_diff;

    nparam.mu_all = param.mu_all .* var_adj;
    nparam.sigma_all = param.sigma_all .* var_adj;
    nparam.mu_I = (param.mu_I - param.mu_all) ./ param.sigma_all .* var_adj;
    nparam.mu_C = (param.mu_C - param.mu_all) ./ param.sigma_all .* var_adj;
    nparam.size_I = param.size_I;
    nparam.size_C = param.size_C;
    %make the adjustments for cov:
    for i=1:size(param.mu_all,2),
      for j=1:size(param.mu_all,2),
        var_adj_cov(i,j) = var_adj(i) * var_adj(j);
      end;
    end;
    t = var_adj_cov;
    nparam.cov_all =  t;
    nparam.cov_C = param.cov_C ./ param.cov_all .* t;
    nparam.cov_I = param.cov_I ./ param.cov_all .* t;
end;
