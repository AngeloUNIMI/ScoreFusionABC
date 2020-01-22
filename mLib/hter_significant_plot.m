function [ci_percentage] = hter_significant_plot(sysA, sysB, n_impostors, n_clients, cost, alpha, test)
%function [ci_percentage] = hter_significant_plot(sysA, sysB, n_impostors, n_clients, cost, alpha, test)
%
% INPUT:
% hter, far and frr each has two values for the two systems to compare
% cost is a variable of 2xN sample points of WER (only the first column is used)
% 1-alpha is the confidence interval
% e.g. alpha = 0.05 to specify 95% confidence interval desired
%
% test could be 1 for one-sided test; 2 for two-sided test (default is two)
% This method implements:  hter(1) - hter(2)
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
if nargin <6,
  alpha = 0.05;
end;
if nargin <7,
  test = 2; %two-sided test
end;

%test the significance:
for i=1:size(sysA.eva.hter_apri,2),
  tmpA =[sysA.eva.hter_apri(i), sysB.eva.hter_apri(i)];
  tmpB =[sysA.eva.far_apri(i),  sysB.eva.far_apri(i)];
  tmpC =[sysA.eva.frr_apri(i),  sysB.eva.frr_apri(i)];
  [tata,tata,tata,ci_percentage(i)] = hter_significant_test(tmpA,tmpB,tmpC, n_impostors, n_clients, alpha,test);
end;

if nargin <= 5,
	subplot(2,1,1);hold off;
    %set(gca, 'Fontsize', 14);
	plot(cost(:,1), sysA.eva.hter_apri*100); hold on;
	plot(cost(:,1), sysB.eva.hter_apri*100, 'r--');
	legend('sysA','sysB');
	xlabel('\alpha');
	ylabel('HTER(%)');
	subplot(2,1,2);hold off;
    %set(gca, 'Fontsize', 14);
	plot(cost(:,1), ci_percentage);
	plot(cost(:,1), ci_percentage);hold on;
	plot(cost(:,1),repmat(90,size(ci_percentage)),'b:');
	plot(cost(:,1),repmat(50,size(ci_percentage)),'b--');
	plot(cost(:,1),repmat(10,size(ci_percentage)),'b-.');
	ylabel('Confidence (%)');
	xlabel('\alpha');
	legend( '% confidence', '90% confidence', '50% confidence','10% confidence');
end;
