function [weight, alpha, eer] = cal_weight_brute(chosen, param, n_samples)
%
% [weight, alpha, eer] = cal_weight_brute(chosen, param, n_samples)
% This function calculate weights using Fisher criterion
% chosen = the chosen column
% param  = the parametric representation of the data given by VR_analysis
% currently solving only 2 dimensions
% to see the weights, do:
% plot(alpha(:,1), eer*100);
% xlabel('\alpha'); ylabel('EER(%)');

alpha = linspace(0,1,n_samples);
alpha =[alpha' 1-alpha'];

for i=1:size(alpha,1),
	[nparam.mu_C, nparam.mu_I] = cal_mu(chosen, param, alpha(i,:));
	[nparam.sigma_C, nparam.sigma_I] = cal_sigma(chosen, param, alpha(i,:));
	
	eer(i) = f_eer(f_ratio(nparam));
end;
[eer_, index] = min(eer);
weight = alpha(index(1),:);


