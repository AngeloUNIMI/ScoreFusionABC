% Funzione che salva il plot dei risultati
% Parametri in ingresso:
%  - nomeDbDatiTotali = nome della base di dati con percorso;
%  - nome = stringa indicativa del nome del metodo utilizzata nel
%           salvataggio dei plot;
% - nCampioni = numero di immagini del dataset;
% - nIn = numero o stringa da aggiungere al nome dei plot salvati
function [EER, deltaFMR_EER, deltaFNMR_EER, FMR_EER, FNMR_EER, soglia, sogliaFMR, sogliaFNMR, zeroFMR] = ...
    indiciStatisticiIncertezza(genuini, impostori, nome, nIn, plottaROCs, dirResults)


if nargin < 6
   dirResults = [];
end %if nargin


if plottaROCs,
    fprintf(1,'Statistiche...\n');
end,

%trasposizione per fare concatenamento meglio
if size(genuini,1) > size(genuini,2)
    genuini = genuini';
end %if size
if size(impostori,1) > size(impostori,2)
    impostori = impostori';
end %if size


%soglie per distribuzione
minimo = min([genuini, impostori]);
massimo = max([genuini, impostori]);
passo = (massimo - minimo) / 1000;
thresholds = minimo : passo : massimo;




REJnira = 0;

FMR=[];
FNMR=[];
dFMR=[];
dFNMR=[];
nFMR = length(impostori);
nFNMR = length(genuini);


parfor ii=1:size(thresholds,2)
    
    if mod(ii, 50000) == 0
        fprintf(1, '\t%d\n', ii)
    end %if mod
    
    FMR(ii) = computeFMR_classic(impostori, REJnira, thresholds(ii));
    FNMR(ii) = computeFNMR_classic(genuini, REJnira, thresholds(ii));
    
    dFMR(ii) = 1.96 * sqrt((FMR(ii) * (1 - FMR(ii))) / nFMR);
    dFNMR(ii) = 1.96 * sqrt((FNMR(ii) * (1 - FNMR(ii))) / nFNMR);
    
end %for ii


%EER
[EER, EERlow, EERhigh, iEER] = computeEERIndex_classic(FMR,FNMR);


if EER > 0
    
    deltaFMR_EER = dFMR(iEER);
    deltaFNMR_EER = dFNMR(iEER);
    FMR_EER = FMR(iEER);
    FNMR_EER = FNMR(iEER);
    soglia = thresholds(iEER);
    
    [zeroFMR, zeroFNMR,  iFMR , iFNMR] = computeZeroFMRFNMR(FMR, FNMR);
    
    sogliaFMR = 0;
    if iFMR ~= 0
        sogliaFMR = thresholds(iFMR);
    end %if iFMR ~= 0
    sogliaFNMR = 0;
    if iFNMR ~= 0
        sogliaFNMR = thresholds(iFNMR);
    end %if iFNMR ~= 0
    
    
    
    % plotting
    if plottaROCs,
        fsfigure
        subplot(2,2,[1,2])
        [ng, xg] = hist(genuini, thresholds ) ;
        ng = 100*ng/(sum(ng));
        
        [ni, xi] = hist(impostori, thresholds ) ;
        ni = 100*ni/(sum(ni));
        plot(xg, ng, 'g-');
        hold on
        plot(xi, ni, 'r-');
        grid on; %savtoner save
        title( ['EER: ', num2str(EER*100), '%   [(\Delta_{FMR} ', num2str(deltaFMR_EER * 100),  '%; \Delta_{FNMR} ', num2str(deltaFNMR_EER * 100),'%) @ 96% Conf. Int.]   [Gen.: ', num2str(nFNMR), '; Imp.: ', num2str(nFMR), ']']  );
        drawnow
        
        
        plotDET(FMR, FNMR, subplot(2,2,3))
        hold on
        plot(EER, EER, 'xr')
        
        plotFMRFNMR(FMR, FNMR, 1:size(thresholds,2), subplot(2,2,4))
    end, %if plottaROCs
    
    
    % indexes.gmsX = genuini;
    % indexes.gmsN = size(genuini,1);
    % indexes.imsX = impostori;
    % indexes.imsN= size(impostori,1);
    % plotMatchDistribution(indexes, subplot(2,2,4))
    
    if plottaROCs,
        saveas(gcf, [dirResults nome, '-', nIn '.jpg'])
        savefig(gcf, [dirResults nome, '-', nIn '.fig'])
    end,%if plottaROCs
    
    if plottaROCs,
        fsfigure
        plot(FMR, FNMR)
        hold on
        plot(FMR+dFMR, FNMR, '--r');
        plot(FMR-dFMR, FNMR, '--r');
        axis([0 1 0 1])
        legend('Mean ROC', 'Gaussian bounds')
        xlabel('FMR'), ylabel('FNMR');
        title('ROC - False Match Rate Uncertainty Bound ')
        saveas(gcf, [dirResults nome, '-', nIn ,'_deltaFMR.jpg'])
        %savefig(gcf, [dirResults nome, '-', nIn ,'_deltaFMR.fig'])
        
        fsfigure
        plot(FMR, FNMR)
        hold on
        plot(FMR, FNMR+dFNMR, '--r');
        plot(FMR, FNMR-dFNMR, '--r');
        axis([0 1 0 1])
        legend('Mean ROC', 'Gaussian bounds')
        xlabel('FMR'), ylabel('FNMR');
        title('ROC - False Non Match Rate Uncertainty Bound ')
        saveas(gcf, [dirResults nome, '-', nIn ,'_deltaFNMR.jpg'])
        %savefig(gcf, [dirResults nome, '-', nIn ,'_deltaFNMR.fig'])
    end, %if plottaROCs
    
else %if EER > 0
    
    EER = 0;
    deltaFMR_EER = 0;
    deltaFNMR_EER = 0;
    FMR_EER = 0;
    FNMR_EER = 0;
    soglia = 0;
    sogliaFMR = 0;
    sogliaFNMR = 0;
    zeroFMR = 0;
    zeroFNMR = 0;
    
    
    
    if plottaROCs,
        % plotting
        fsfigure
        subplot(2,2,[1,2])
        [ng, xg] = hist(genuini, thresholds ) ;
        ng = 100*ng/(sum(ng));
        
        [ni, xi] = hist(impostori, thresholds ) ;
        ni = 100*ni/(sum(ni));
        plot(xg, ng, 'g-');
        hold on
        plot(xi, ni, 'r-');
        grid on; savtoner save
        title( ['EER: ', num2str(EER*100), '%   [(\Delta_{FMR} ', num2str(deltaFMR_EER * 100),  '%; \Delta_{FNMR} ', num2str(deltaFNMR_EER * 100),'%) @ 96% Conf. Int.]   [Gen.: ', num2str(nFNMR), '; Imp.: ', num2str(nFMR), ']']  );
        drawnow
    end, %if plottaROCs
    
    if plottaROCs,
        saveas(gcf, [dirResults nome, '-', nIn '.jpg'])
        savefig(gcf, [dirResults nome, '-', nIn '.fig'])
    end, %if plottaROCs
    
end %if EER > 0

%save_to_base(1);

if plottaROCs,
    fsfigure
    loglog(FMR, FNMR, 'LineWidth', 2);
    xlabel('FMR','FontSize',13), ylabel('FNMR','FontSize',13);
    hold on
    %plot(EER, EER, 'xr')
    plot(EER, EER, 'or','MarkerSize',15, 'LineWidth', 3)
    axis([0. 1 0. 1]);
    axis square
    set(gca,'FontSize',13)
    grid on
    title('ROC - log axes');
    saveas(gcf, [dirResults nome, '-', nIn '_logroc.jpg'])
    savefig(gcf, [dirResults nome, '-', nIn '_logroc.fig'])
end, %if plottaROCs

