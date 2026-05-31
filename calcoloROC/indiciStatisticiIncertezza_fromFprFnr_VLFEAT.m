function [EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000] = ...
    indiciStatisticiIncertezza_fromFprFnr_VLFEAT(fpr, fnr, numGenuini_test, numImpostori_test, nome, nIn, dirResults, plottaROCs)


tnr = 1 - fpr;
tpr = 1 - fnr;


%s = max(find(tnr > tpr));
%[EER, EERlow, EERhigh, iEER] = computeEERIndex_classic(fpr, fnr);
[EER, s] = computeEER_classic_minDiffFprFnr(fpr, fnr);
[zeroFMR, zeroFNMR] = computeZeroFMRFNMR(fpr, fnr);
[FMR1000, ~] = computeFMR1000(fpr, fnr);


dFMR = 1.96 .* sqrt((fpr .* (1 - fpr)) / numImpostori_test);
dFNMR = 1.96 .* sqrt((fnr .* (1 - fnr)) / numGenuini_test);
deltaTMR_EER = 1.96 * sqrt((tpr(s) * (1 - tpr(s))) / (numImpostori_test+numGenuini_test));
deltaTNMR_EER = 1.96 * sqrt((tnr(s) * (1 - tnr(s))) / (numImpostori_test+numGenuini_test));
deltaFMR_EER = 1.96 * sqrt((fpr(s) * (1 - fpr(s))) / (numImpostori_test+numGenuini_test));
deltaFNMR_EER = 1.96 * sqrt((fnr(s) * (1 - fnr(s))) / (numImpostori_test+numGenuini_test));


%plot
if plottaROCs

    fsfigure
    plot(fpr, fnr);
    hold on
    plot(fpr+dFMR, fnr, '--r');
    plot(fpr-dFMR, fnr, '--r');
    axis([0 1 0 1])
    legend('Mean ROC', 'Gaussian bounds')
    xlabel('FMR'), ylabel('FNMR');
    title('ROC - False Match Rate Uncertainty Bound ')
    saveas(gcf, [dirResults nome, '-', nIn ,'_deltaFMR.jpg'])
    %savefig(gcf, [dirResults nome, '-', nIn ,'_deltaFMR.fig'])
    
    fsfigure
    plot(fpr, fnr)
    hold on
    plot(fpr, fnr+dFNMR, '--r');
    plot(fpr, fnr-dFNMR, '--r');
    axis([0 1 0 1])
    legend('Mean ROC', 'Gaussian bounds')
    xlabel('FMR'), ylabel('FNMR');
    title('ROC - False Non Match Rate Uncertainty Bound ')
    saveas(gcf, [dirResults nome, '-', nIn ,'_deltaFNMR.jpg'])
    %savefig(gcf, [dirResults nome, '-', nIn ,'_deltaFNMR.fig'])
    
    fsfigure
    loglog(fpr, fnr, 'LineWidth', 2);
    xlabel('FMR','FontSize',13), ylabel('FNMR','FontSize',13);
    hold on
    %plot(EER, EER, 'xr')
    plot(EER, EER, 'or','MarkerSize',15, 'LineWidth', 3)
    axis([0. 1 0. 1]);
    axis square
    set(gca,'FontSize',13)
    grid on
    title({'ROC - log axes', ...
        [sprintf('EER: %.4f%%',EER*100) '; ' sprintf('FMR1000: %.4f%%',FMR1000*100)], ...
        ['[(\Delta_{FRR} ' sprintf('%.7f%%',deltaTNMR_EER*100) ...
        '; \Delta_{FAR} ' sprintf('%.7f%%) @ 96%% Conf. Int.] [Gen.: %d; Imp.: %d]',deltaTMR_EER*100, numGenuini_test, numImpostori_test)]});
    saveas(gcf, [dirResults nome, '-', nIn '_logroc.jpg'])
    %savefig(gcf, [dirResults nome, '-', nIn '_logroc.fig'])
    
end %if plottaROCs



