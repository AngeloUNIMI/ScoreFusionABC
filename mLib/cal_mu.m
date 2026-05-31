function [mu_norm_C, mu_norm_I] = cal_mu(chosen, param, alpha)

factor = alpha;
diff_C = (param.mu_C(chosen));
diff_I = (param.mu_I(chosen));

mu_norm_C = diff_C * factor';
mu_norm_I = diff_I * factor';

