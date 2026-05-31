function [sigma_C, sigma_I, var_C_AV, var_I_AV, var_C_COV, var_I_COV] = cal_sigma(chosen, param, alpha)

if (size(chosen, 2) ~= size(alpha,2)),
    error('The size of alpha and chosen in the input arguments do not have same size');
end;

%calculate the weighted covariance matrix
for i=1:size(chosen,2),
  for j=1:size(chosen,2),
    alpha_ = alpha(i) * alpha(j);
    cov_C(i,j) = param.cov_C(chosen(i), chosen(j));
    cov_I(i,j) = param.cov_I(chosen(i), chosen(j));

    norm_cov_C(i,j) = alpha_ * cov_C(i,j);
    norm_cov_I(i,j) = alpha_ * cov_I(i,j);
  end;
end;

%norm_cov_C
%norm_cov_I

N = size(chosen, 2);

sum_C = sum(sum(norm_cov_C));
sum_I = sum(sum(norm_cov_I));

sigma_C = sqrt(  sum_C );
sigma_I = sqrt(  sum_I );

var_C_AV = sum(diag(norm_cov_C));
var_I_AV = sum(diag(norm_cov_I));

t = eye(N);
index = find( t <=0);

var_C_COV = sum(norm_cov_C(index));
var_I_COV = sum(norm_cov_I(index));
