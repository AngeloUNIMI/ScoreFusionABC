function draw_theory(chosen, param)

if (length(chosen)==0)
    chosen = [1 2];
end;

if (size(chosen,2) > 2),
    error('This function cannot handle more than two dimension');
end;

if (1==0),
	[mu_C, mu_I] = cal_mu(chosen, param, alpha);
	[sigma_C, sigma_I, var_C_AV, var_I_AV, var_C_COV, var_I_COV] = cal_sigma(chosen, param, alpha);
	fratio = (mu_C - mu_I) ./ (sigma_C + sigma_I);

	%calculate threshold
	thrd = (mu_I * sigma_C + mu_C * sigma_I) / (sigma_I + sigma_C);

	%calculate the parameters
	angle = atan(alpha(2) / alpha(1));
	other_angle = pi/2 - angle;
	m = - tan(other_angle);

	magnitude = sqrt(sum(alpha .^ 2));

	c = thrd/magnitude * cos(angle);

	%min_max_x1 = [min_max_x1 min(x) max(x)];
	%min_max_y1 = [min_max_x1 min(y) max(y)];

	%decision boundary
	%x= linspace(min(min_max_x1),max(min_max_x1),10);
	%y = m * x + c;
	%plot(x,y,'k-');
end;

mu_C = param.mu_C(chosen);
mu_I = param.mu_I(chosen);

cov_C = [param.cov_C(chosen(1), chosen(1)), param.cov_C(chosen(1), chosen(2));
    param.cov_C(chosen(2), chosen(1)), param.cov_C(chosen(2), chosen(2))];

cov_I = [param.cov_I(chosen(1), chosen(1)), param.cov_I(chosen(1), chosen(2));
    param.cov_I(chosen(2), chosen(1)), param.cov_I(chosen(2), chosen(2))];

hC = my_plot_ellipses(mu_C', cov_C, 1, 'g-');
hI = my_plot_ellipses(mu_I', cov_I, 1, 'k-');
plot(mu_C(1), mu_C(2), 'g+', 'MarkerSize', 20, 'LineWidth', 3);
plot(mu_I(1), mu_I(2), 'k+', 'MarkerSize', 20, 'LineWidth', 3);
grid on;

function [x,y] = rotate_circle(x0,y0, sigma, angle, n_samples)

	theta=linspace(0,2*pi,n_samples);
	x=sigma(1)*sin(theta);
	y=sigma(2)*cos(theta);
	%rotation matrix
	R=[cos(angle) -sin(angle); sin(angle) cos(angle)];
	out = R' * ([x; y] );
	x = out(1,:) + x0;
	y = out(2,:) + y0;



function h = my_plot_ellipses(mu, sigma, weight, signs);

D = size(mu, 1);

if D ~= 2
	error('Can plot only 2D objects.');
end

[x,y,z] = cylinder([2 2], 40);
xy = [ x(1,:) ; y(1,:) ];

%plot(data(:,1), data(:,2), 'rx');

hold on
C = size(mu, 2);
for c = 1:C
	mxy = chol(sigma(:,:,c))' * xy;
	x = mxy(1,:) + mu(1,c);
	y = mxy(2,:) + mu(2,c);
	z = ones(size(x))*weight(c);
	h(c) = plot3(x,y,z, signs);
end;
drawnow;
%hold off