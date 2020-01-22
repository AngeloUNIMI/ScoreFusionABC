function Make_DET(max_scale)
% function Make_DET(max_scale)
%
% Make_DET creates a plot for displaying the Detection Error Trade-off
% for a detection system.  The detection performance is characterized by
% the miss and false alarm probabilities, with the axes scaled and
% labeled so that a normal Gaussian distribution will plot as a straight
% line.
%
%	The miss probability is plotted along the y axis.
%	The false alarm probability is plotted along the x axis.
%
% Make_DET sets up the plot with tick marks and with limits
% as determined by Set_DET_limits.  The scaling of the two
% probability axes is controlled to be the same.
%
% For most DET plotting applications, the user needn't call
% Make_DET.  Make_DET is called by wer.

if (nargin <1),
   max_scale = 0.8;
end;

pticks = [0.00001 0.00002 0.00005 0.0001   0.0002   0.0005 ...
          0.001   0.002   0.005   0.01     0.02     0.05 ...
          0.1     0.2     0.4     0.6      0.8      0.9 ...
          0.95    0.98    0.99    0.995    0.998    0.999 ...
          0.9995  0.9998  0.9999  0.99995  0.99998  0.99999];
xlabels = [' 0.001';' 0.002';' 0.005';' 0.01 ';' 0.02 '; ...
     ' 0.05 ';'  0.1 ';'  0.2 ';'  0.5 ';'   1  ';'   2  '; ...
     '   5  ';'  10  ';'  20  ';'  40  ';'  60  ';'  80  '; ...
     '  90  ';'  95  ';'  98  ';'  99  ';' 99.5 ';' 99.8 '; ...
     ' 99.9 ';' 99.95';' 99.98';' 99.99';'99.995';'99.998'; ...
     '99.999'];
ylabels = [' 0.001';' 0.002';' 0.005';'  0.01';'  0.02'; ...
     '  0.05';'   0.1';'   0.2';'   0.5';'     1';'     2'; ...
     '     5';'    10';'    20';'    40';'    60';'    80'; ...
     '    90';'    95';'    98';'    99';'  99.5';'  99.8'; ...
     '  99.9';' 99.95';' 99.98';' 99.99';'99.995';'99.998'; ...
     '99.999'];

%---------------------------------
% Get the min/max values of P_miss and P_fa to plot

Pmiss_min = 0.0005+eps;
Pmiss_max = max_scale-eps;
Pfa_min = 0.0005+eps;
Pfa_max = max_scale-eps;

%Pmiss_min = 0.005+eps;
%Pmiss_max = 0.7-eps;
%Pfa_min = 0.005+eps;
%Pfa_max = 0.7-eps;
%---------------------------------
% Find the subset of tick marks to plot

ntick = max(size(pticks));

for n=ntick:-1:1
	if (Pmiss_min <= pticks(n))
		tmin_miss = n;
	end
	if (Pfa_min <= pticks(n))
		tmin_fa = n;
	end
end
for n=1:1:ntick
	if (pticks(n) <= Pmiss_max)
	    	tmax_miss = n;
	end
	if (pticks(n) <= Pfa_max)
		tmax_fa = n;
	end
end

%---------------------------------
% Plot the DET grid

vss = version;
vs = str2num(vss(1));

set (gca, 'xlim', ppndf([Pfa_min Pfa_max]));
set (gca, 'xtick', ppndf(pticks(tmin_fa:tmax_fa)));
if vs == 4
 set (gca, 'xticklabels', xlabels(tmin_fa:tmax_fa,:));
end
if vs >= 5
 set (gca, 'xticklabel', xlabels(tmin_fa:tmax_fa,:));
end
set (gca, 'xgrid', 'on');
xlabel ('FA [%]');

set (gca, 'ylim', ppndf([Pmiss_min Pmiss_max]));
set (gca, 'ytick', ppndf(pticks(tmin_miss:tmax_miss)));
if vs == 4
 set (gca, 'yticklabels', ylabels(tmin_miss:tmax_miss,:));
end
if vs >= 5
 set (gca, 'yticklabel', ylabels(tmin_miss:tmax_miss,:));
end
set (gca, 'ygrid', 'on');
ylabel ('FR [%]');

%axis('equal');
axis('image');
%axis(axis);

axis([ppndf([Pfa_min Pfa_max]) ppndf([Pmiss_min Pmiss_max])]);











