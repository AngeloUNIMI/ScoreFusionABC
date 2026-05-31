function [hter_min, thrd_min, x] = hter(wolves, sheep,dodisplay,holdon)
%function [hter_min, thrd_min, x] = hter(wolves, sheep,dodisplay,ignore_value,holdon)
% holdon = 1 will plot on current active figure
% holdon = 0 will overwrite the current active figure
% dodisplay = 1 will plot all the graphs
% dodisplay = 3 will plot only the density
% defautl ignore_value is -1000

n_hist_wolves = 0;
n_hist_sheep = 0;
if nargin < 3,
  dodisplay = 0;
end
if nargin < 4,
  holdon = 0;
end

[f_I,x_I] = ecdf(wolves);
[f_C,x_C] = ecdf(sheep);
%figure(10);plot(x_I,f_I);
%figure(11);plot(x_C,f_C);

%sample the function
bin_minmax = [min(sheep), max(sheep), min(wolves), max(wolves)];
%binspace = linspace(min(bin_minmax), max(bin_minmax), bin_class);
x = union(x_I, x_C);

for i=1:size(x,1), %thrd
  index = find(x_C >=  x(i));
  if (size(index,1) == 0)
    new_f_C(i) = 1;
  else
    new_f_C(i) = f_C(index(1));
  end;

  index = find(x_I >=  x(i));
  if (size(index,1) == 0)
    new_f_I(i) = 1;
  else
  new_f_I(i) = f_I(index(1));
  end;
end;

new_f_I= new_f_I';
new_f_C= new_f_C';

[min_value, min_index] = min( abs(1-new_f_I -new_f_C) );

%figure(2);plot(x,abs(1-new_f_I -new_f_C));

thrd_min = x(min_index);
hter_min = (1- new_f_I(min_index) + new_f_C(min_index))/2;

if holdon == 0,
  signs = {'b', 'r'};
else
  signs = {'b--', 'r--'};
end;

if (dodisplay==1),
  
  %density estimation
  subplot(2,2,1);  
  [fI,xI] = ksdensity(wolves);
  [fC,xC] = ksdensity(sheep);
  if holdon == 0, hold off; else hold on; end;
  plot(xC, fC,signs{1});
  hold on;
  plot(xI, fI,signs{2});
  ylabel('Density');
  xlabel('Scores');
  title('(a)');
  
  %plot ecdf curve
  subplot(2,2,2);
  if holdon == 0, hold off; else hold on; end
  plot(x,new_f_C,signs{1});
  hold on;
  plot(x,1-new_f_I,signs{2});
  xlabel('Scores');
  ylabel('FRR, FAR');
  title('(b)');
  
  %debug use only:
  %plot(x_I,1-f_I,'c');
  %hold on;
  %plot(x_C,f_C,'m');

  %plot the hter curve
  subplot(2,2,3);
  if holdon == 0, hold off; else hold on; end
  hter_all = (1-new_f_I +new_f_C)/2;
  plot(x,hter_all,signs{1});
  xlabel('Scores');
  ylabel('HTER');
  title('(c)');
  
  %roc curve
  subplot(2,2,4);
  if holdon == 0, hold off; else hold on; end
  plot(1-new_f_I, new_f_C,signs{1});
  xlabel('FAR');
  ylabel('FRR');
  title('(d)');  
end;

if (dodisplay==2),
  [fI,xI] = ksdensity(wolves);
  [fC,xC] = ksdensity(sheep);
  if holdon == 0, hold off; else hold on; end;
  plot(xC, fC,signs{1});
  hold on;
  plot(xI, fI,signs{2});
  ylabel('Density');
  xlabel('Scores');
end;

if (dodisplay==3),
  if holdon == 0, hold off; else hold on; end
  hter_all = (1-new_f_I +new_f_C)/2;
  plot(x,hter_all,signs{1});
  xlabel('Scores');
  ylabel('HTER');
end;