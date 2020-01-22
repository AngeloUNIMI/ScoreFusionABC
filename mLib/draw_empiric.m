function [samples_wolves, samples_sheep] = draw_empiric(wolves, sheep, percentage, signs)

if (nargin < 3),
    samples_w = 1:size(wolves,1);
    samples_s = 1:size(sheep,1);
else
    size_w = round(size(wolves,1) * percentage);
    size_s = round(size(sheep,1) * percentage);
    index_w = randperm(size(wolves,1));
    index_s = randperm(size(sheep,1));
    samples_w = index_w(1:size_w);
    samples_s = index_s(1:size_s);
end;

if (nargin < 4),
    signs = {'b+', 'r.'};
end;
%hold off;
plot(sheep(samples_s,1),sheep(samples_s,2),signs{1});
hold on;
plot(wolves(samples_w,1),wolves(samples_w,2),signs{2}); 

samples_wolves = [wolves(samples_w,1),wolves(samples_w,2)];
samples_sheep = [sheep(samples_s,1),sheep(samples_s,2)];
grid on;