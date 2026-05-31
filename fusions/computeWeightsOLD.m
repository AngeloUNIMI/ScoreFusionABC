function weight = computeWeightsOLD(EERs, eer_thresholds, scoresT_norm, qualNorm, genImp, dirScores, numGenuini, numImpostori, numInd, numSamples, kfold)

genuini = zeros(numel(dirScores), numGenuini);
impostori = zeros(numel(dirScores), numImpostori);
for k = 1 : numel(dirScores)
    [genuini(k, :), impostori(k, :)] = dividiScoresGenImp(scoresT_norm(:,k) .* qualNorm(:,k), genImp);
end %for k
genuini = genuini';
impostori = impostori';

%10 fold validation per individui
sumInvOLD = 0;
weight = zeros(1, numel(dirScores));
weightV = zeros(1, numel(dirScores));
OLD = zeros(1, numel(dirScores));
for numval = 1 : kfold
    
    %estraiamo gen e imp per l'iterazione
    [ind_gen, ind_imp] = compIndNfoldPerson(numGenuini, numImpostori, numInd, numSamples, kfold, numval);
    
    for k = 1 :numel(dirScores)
        impsOLD = impostori(ind_imp, k);
        impsOLDn = impsOLD(impsOLD >= eer_thresholds(k));
        gensOLD = genuini(ind_gen, k);
        gensOLDn = gensOLD(gensOLD < eer_thresholds(k));
        
        OLD(k) = std([impsOLDn; gensOLDn]) * EERs(k);
        sumInvOLD = sumInvOLD + 1/OLD(k);
    end %for j = 1 :numel(dirScores)
    
    for k = 1 :numel(dirScores)
        weight(1, k) = (1/OLD(k)) / (sumInvOLD);
    end %for j = 1 :numel(dirScores)
    
    weightV = weightV + weight;
    
end %for g
weight = weightV / kfold;


% 
% y_gen = randsample(numel(genuini(:,1)), round(numel(genuini(:,1))*perc));
% y_imp = randsample(numel(impostori(:,1)), round(numel(impostori(:,1))*perc));
% param = VR_analysis(impostori(y_imp, :), genuini(y_gen, :));
% weight = cal_weight_fisher(1:numel(dirScores), param);

