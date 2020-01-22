function [alpha, norm_cov_inv] = cal_weight_fisher(chosen, dset)
%
% [alpha, norm_cov_inv]  = cal_weight(chosen, param)
% This function calculate weights using Fisher criterion
% chosen = the chosen column
% param  = the parametric representation of the data given by VR_analysis

%make covariance matrix
for i=1:size(chosen,2),
  for j=1:size(chosen,2),

    norm_cov_C(i,j) = dset.cov_C(chosen(i), chosen(j));
    norm_cov_I(i,j) = dset.cov_I(chosen(i), chosen(j));
  end;
end;
%inverse within-class cov matrix
%see bishop pg 108
factor_C = dset.size_C / (dset.size_C + dset.size_I);
factor_I = 1 - factor_C;
Sw_1 = inv(factor_C * norm_cov_C + factor_I * norm_cov_I);
mean_diff = dset.mu_C(chosen) - dset.mu_I(chosen);
norm_cov_inv = Sw_1 * mean_diff';

%calculate alpha: sum to 1
for i=1:size(chosen,2),	
  alpha(i) = sum(norm_cov_inv(i,:));
end;
alpha = alpha / sum(alpha); %normalise it