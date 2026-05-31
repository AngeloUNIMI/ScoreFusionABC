function y = sigmoid_inv(x, alpha)

x = max(x, -1+eps);
x = min(x, 1-eps);
% sigmoid_inv prodcues an inverse function of sigmoid
if (nargin < 2),
    alpha= 2;
end;
%map = zeros(n_samples,2);
%map(:,1) = linspace(range(1),range(2),n_samples)';
%sigmoid function with output range between -1 and 1
%map(:,2) = 1./(1+exp(alpha * map(:,1) ).^(-1)) * 2 -1;
%plot( map(:,2), -log( 2 ./ (map(:,2) +1)-1 ) /alpha);
log_term = 2 ./ (x +1)-1 ;
%log_term = max(log_term, eps);
y = -log( log_term ) /alpha;

y = max(y, -18);
y = min(y, 18); 