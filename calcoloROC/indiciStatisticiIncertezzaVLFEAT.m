function [EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000, fpr, fnr, eer_threshold, fmr1000_threshold] = ...
    indiciStatisticiIncertezzaVLFEAT(gen_lr, imp_lr, nome, nIn, dirResults, plottaROCs)

%create the structure for vl_roc
labelsGenuini = ones(size(gen_lr))';
labelsImpostors = -1 * ones(size(imp_lr))';

allLabels = [labelsGenuini; labelsImpostors];
allScores = [gen_lr'; imp_lr'];
allScoresOrd = sort(allScores, 'descend');

%calcolo roc
[tpr, tnr, info] = vl_roc(allLabels, allScores);
fpr = 1 - tnr;
fnr = 1 - tpr;

%s = max(find(tnr > tpr));
%EER = info.eer;
[EER, s, eer_threshold] = computeEER_classic_minDiffFprFnr(fpr, fnr, allScoresOrd);
[zeroFMR, zeroFNMR] = computeZeroFMRFNMR(fpr, fnr);
[FMR1000, ~, fmr1000_threshold] = computeFMR1000(fpr, fnr, allScoresOrd);

dFMR = 1.96 .* sqrt((fpr .* (1 - fpr)) / length(imp_lr));
dFNMR = 1.96 .* sqrt((fnr .* (1 - fnr)) / length(gen_lr));

deltaTMR_EER = 1.96 * sqrt((tpr(s) * (1 - tpr(s))) / length(allScores));
deltaTNMR_EER = 1.96 * sqrt((tnr(s) * (1 - tnr(s))) / length(allScores));
deltaFMR_EER = 1.96 * sqrt((fpr(s) * (1 - fpr(s))) / length(allScores));
deltaFNMR_EER = 1.96 * sqrt((fnr(s) * (1 - fnr(s))) / length(allScores));


%plot
if plottaROCs

    fsfigure,
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
    histogram(gen_lr, 1000, 'DisplayStyle', 'stairs', 'EdgeColor', 'g');
    hold on
    histogram(imp_lr, 1000, 'DisplayStyle', 'stairs', 'EdgeColor', 'r');
    title({[sprintf('EER: %.4f%%',EER*100) '; ' sprintf('FMR1000: %.4f%%',FMR1000*100)], ['[(\Delta_{FRR} ' sprintf('%.7f%%',deltaTNMR_EER*100) ...
        '; \Delta_{FAR} ' sprintf('%.7f%%) @ 96%% Conf. Int.] [Gen.: %d; Imp.: %d]',deltaTMR_EER*100, length(gen_lr), length(imp_lr))]});
    saveas(gcf, [dirResults nome, '-', nIn '.jpg'])
    %savefig(gcf, [dirResults nome, '-', nIn '.fig'])
    
    
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
        '; \Delta_{FAR} ' sprintf('%.7f%%) @ 96%% Conf. Int.] [Gen.: %d; Imp.: %d]',deltaTMR_EER*100, length(gen_lr), length(imp_lr))]});
    saveas(gcf, [dirResults nome, '-', nIn '_logroc.jpg'])
    %savefig(gcf, [dirResults nome, '-', nIn '_logroc.fig'])
    
end %if plottaROCs



