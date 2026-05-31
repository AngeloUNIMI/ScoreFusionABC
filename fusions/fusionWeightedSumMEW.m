function [] = fusionWeightedSumMEW(scoresT_norm, qualNorm, genImp, dirScores, dirResults, normData, nomedb, nomi_matchers, ...
    numGenuini, numImpostori, numInd, numSamples, kfold, fidResults, plottaROCs)

%N. Damer, A. Opel and A. Nouak, "Biometric source weighting in multi-biometric fusion: Towards a generalized and robust solution,"
%2014 22nd European Signal Processing Conference (EUSIPCO), Lisbon, 2014, pp. 1382-1386.

%init
numScores = size(scoresT_norm, 1);

%weight computation according to paper
weight = computeWeightsMEW(scoresT_norm, qualNorm, genImp, dirScores, numGenuini, numImpostori, numInd, numSamples, kfold);

%score fusion
%(if necessary parfor -> for)
scoresWeightedSum = zeros(numScores, 1);
parfor i = 1 : numScores
    scoreSum = 0;
    for k = 1 : numel(dirScores)
        scoreSum = scoreSum + weight(k) * scoresT_norm(i, k) * qualNorm(i,k);
    end %for k
    scoresWeightedSum(i) = scoreSum;
end %for i

%divide in genuine and impostors
[genuini, impostori] = dividiScoresGenImp(scoresWeightedSum, genImp);
saveGenImp(genuini, impostori, [dirResults 'distr_weighted_sum.mat']);

%biometric error measures
labelTest = [nomedb '_WSUM_MEW_' [nomi_matchers{:}]];
[EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000, ~, ~, eer_threshold, fmr1000_threshold] = ...
    indiciStatisticiIncertezzaVLFEAT(genuini, impostori, 'R', labelTest, dirResults, plottaROCs);

%save computed weights
save([dirResults 'weights_mew'], 'weight');

%print results on file
fprintf(fidResults, '%s\r\n', labelTest);
fprintf(fidResults, 'Weights computed using k-fold validation\r\n');
fprintf(fidResults, 'K = %d\r\n', kfold);
fprintf(fidResults, 'EER (%%): %f\r\n', EER*100);
fprintf(fidResults, 'EER threshold: %f\r\n', eer_threshold);
fprintf(fidResults, 'deltaFMR_EER (%%): %f\r\n', deltaFMR_EER*100);
fprintf(fidResults, 'deltaFNMR_EER (%%): %f\r\n', deltaFNMR_EER*100);
fprintf(fidResults, 'ZeroFMR (%%): %f\r\n', zeroFMR*100);
fprintf(fidResults, 'FMR_1000 (%%): %f\r\n', FMR1000*100);
fprintf(fidResults, 'FMR 1000 threshold: %f\r\n', fmr1000_threshold);
fprintf(fidResults, 'Weights: \r\n');
for k = 1 : numel(dirScores)
    fprintf(fidResults, '%f: \r\n', weight(k));
end %for k
fprintf(fidResults, '\r\n\r\n');



%%%%%%%%%
pause(1)
%%%%%%%%%