function [parametric] =VR_analysis(wolves, sheep, parametric)
%
% [parametric] =VR_analysis(wolves, sheep)
%    This function produces class-dependent Gaussian parameters
%    mu_all and sigma_all.
%
% [parametric] =VR_analysis(wolves, sheep, parametric)
% is similar to the first function except the parametric
% variable will be preserved.
%
% The parametric variable has the following structure:
%    mu_all      : the overall (client and impostor) mean
%    sigma_all   : the overall standard diviation
%                  The above two parameters are needed for normalisation
%    mu_C        : the mean of client scores
%    mu_I        : the mean of impostor scores
%    cov_all     : the overall covariance matrix
%    cov_C       : the client covariance matrix
%    cov_I       : the impostor covariance matrix 
%    size_C      : the total number of client accesses
%    size_I      : the total number of impostor accesses
%
% See also: load_raw_scores

%wolves and sheep could be vector!
if (size(wolves,2) ~= size(sheep,2)),
  error('Error\n');
end;

parametric.mu_all = mean([wolves;sheep]);
parametric.sigma_all = std([wolves;sheep]);
parametric.mu_C = mean([sheep]);
parametric.mu_I = mean([wolves]);
parametric.cov_all = cov([wolves;sheep]);
parametric.cov_C = cov([sheep]);
parametric.cov_I = cov([wolves]);
parametric.sigma_C = sqrt(diag(parametric.cov_C))';
parametric.sigma_I = sqrt(diag(parametric.cov_I))';
parametric.size_C = size(sheep,1);
parametric.size_I = size(wolves,1);