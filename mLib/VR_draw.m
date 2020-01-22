function VR_draw(wolves, sheep, percentage, param, the_two_columns)
% draw the first two dimension unless stated otherwise
% if alpha is not set, average will be used; otherwise weighted sum will be used
% as decision boundary

if (nargin < 5)
    the_two_columns = [1 2];
end;

%draw empirical, theoretical scatter plot and the decision boundary
hold off;
[samples_w, samples_s] = draw_empiric(wolves, sheep, percentage);% plot 1% of data
hold on;
draw_theory(the_two_columns, param);

