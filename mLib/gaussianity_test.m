function out = gaussianity_test(wolves, sheep,out)
[nwolves0, temp] = normalise_scores(wolves, sheep, mean(wolves), std(wolves));
[temp, nsheep0] = normalise_scores(wolves, sheep, mean(sheep), std(sheep));
f = factor(size(wolves,2));
if (size(f,2) > 2),
    f(2) = prod(  f(2:size(f,2)));
    f(3:size(f,2)) = [];
end;
figure;
for i=1:size(wolves,2),
    subplot(f(1), f(2), i);
    
    [out.test.I_h(i),out.test.I_p(i),out.test.I_ks(i), out.test.I_cutoff(i)] =kstest(nwolves0(:,i),[],0.2,0);
    hold off;
    cdfplot(nwolves0(:,i));
    hold on;
    bound = [min(nwolves0(:,i)), max(nwolves0(:,i))];
    xx = linspace(bound(1), bound(2), 100);
    plot(xx, normcdf(xx),'r--');
    txt = sprintf('CDF: wolves %d', i);
    title(txt);
    if (i == 1),legend('Empirical', 'Gaussian');  end;
end;

figure;
for i=1:size(sheep,2),
    subplot(f(1), f(2), i);
    
    [out.test.C_h(i),out.test.C_p(i),out.test.C_ks(i), out.test.C_cutoff(i)] =kstest(nsheep0(:,i));%,[],0.05,0);
    hold off;
    cdfplot(nsheep0(:,i));
    hold on;
    bound = [min(nsheep0(:,i)), max(nsheep0(:,i))];
    xx = linspace(bound(1), bound(2), 100);
    plot(xx, normcdf(xx),'r--');
    txt = sprintf('CDF: sheep %d', i);
    title(txt);
    if (i == 1),legend('Empirical', 'Gaussian');  end;
end;
