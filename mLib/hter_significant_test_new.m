function [significant, z,ci,ci_percentage] = hter_significant_test_new(far, frr, n_impostors, n_clients, alpha)
%function [significant, z,ci,ci_percentage] = hter_significant_test(hter, far, frr, n_impostors, n_clients, alpha,test)
%
% INPUT:
% hter, far and frr each has two values for the two systems to compare
% 1-alpha is the confidence interval
% e.g. alpha = 0.05 to specify 95% confidence interval desired
%
% test could be 1 for one-sided test; 2 for two-sided test
% one-sided test not implemented yet!
% for one-sided test:  hter(1) - hter(2). 
% Hence hter(1) > hter(2), so we try to test that 2 is better than 1
%
% OUTPUT:
% significant is a boolean variable: 
%     1 means significant
%     0 means not significant
% significant_level is the z value
%
% The output variable ci_percentage
% 100% confidence: affirm this;
% 50%  confidence: not sure at all
% 0%   confidence: contrary, 1 is better than 2

%the significant level is 95% by default
if nargin <5,
  alpha = 0.05;
end;
portion = 1-alpha/2;
%acutally the upper and lower bound is:
%portion = [alpha/2 1-alpha/2];

%the confidence interval
ci = norminv(portion,0,1);

%for the INDEPENDENT CASE only
%if test == 2,
%  diff_hter = abs(hter(1) - hter(2));
%else
hter(:,1) = (far(:,1) + frr(:,1))/2;
hter(:,2) = (far(:,2) + frr(:,2))/2;

diff_hter = hter(:,1) - hter(:,2)
%end;
tmp1 = far(:,1) * (1-far(:,1)) + far(:,2) * (1-far(:,2));
tmp1 = tmp1 / (4 * n_impostors);
tmp2 = frr(:,1) * (1-frr(:,1)) + frr(:,2) * (1-frr(:,2));
tmp2 = tmp2 / (4 * n_clients);

z_abs = abs(diff_hter) ./ sqrt(tmp1 + tmp2);
z = diff_hter ./ sqrt(tmp1 + tmp2);

significant = z_abs > ci;

%manage the output
if nargout >= 4,
  ci_percentage = normcdf(z) * 100
  ci_percentage_abs = normcdf(z_abs) * 100
end;