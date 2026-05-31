function fusionMin(scoresT_norm, qualNorm, genImp, dirScores, dirResults, normData, nomedb, nomi_matchers, fidResults, plottaROCs)

%init
numScores = size(scoresT_norm, 1);
scoreMin = zeros(numScores, 1);

%score fusion
%(if necessary parfor -> for)
parfor i = 1 : numScores
    minF = 1e6;
    for k = 1 : numel(dirScores)
        if (scoresT_norm(i, k)) < minF * qualNorm(i,k)
            minF = scoresT_norm(i, k) * qualNorm(i,k);
        end %if scores
    end %for k
    scoreMin(i) = minF;
end %for i

%divide in genuine and impostors
[genuini, impostori] = dividiScoresGenImp(scoreMin, genImp);
saveGenImp(genuini, impostori, [dirResults 'distr_min']);

%biometric error measures
labelTest = [nomedb '_MIN_' [nomi_matchers{:}]];
[EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000] = indiciStatisticiIncertezzaVLFEAT(genuini, impostori, 'R', labelTest, dirResults, plottaROCs);

%print results on file
fprintf(fidResults, '%s\r\n', labelTest);
fprintf(fidResults, 'EER (%%): %f\r\n', EER*100);
fprintf(fidResults, 'deltaFMR_EER (%%): %f\r\n', deltaFMR_EER*100);
fprintf(fidResults, 'deltaFNMR_EER (%%): %f\r\n', deltaFNMR_EER*100);
fprintf(fidResults, 'ZeroFMR (%%): %f\r\n', zeroFMR*100);
fprintf(fidResults, 'FMR_1000 (%%): %f\r\n', FMR1000*100);
fprintf(fidResults, '\r\n\r\n');



%%%%%%%%%
pause(1)
%%%%%%%%%