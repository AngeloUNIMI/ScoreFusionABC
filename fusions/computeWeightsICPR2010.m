function weight = computeWeightsICPR2010(scoresT_norm, qualNorm, genImp, dirScores, numGenuini, numImpostori, numInd, numSamples, kfold)

genuini = zeros(numel(dirScores), numGenuini);
impostori = zeros(numel(dirScores), numImpostori);
for k = 1 : numel(dirScores)
    [genuini(k, :), impostori(k, :)] = dividiScoresGenImp(scoresT_norm(:,k) .* qualNorm(:,k), genImp);
end %for k
genuini = genuini';
impostori = impostori';

%10 fold validation per individui
sumInvNCW = 0;
weight = zeros(1, numel(dirScores));
weightV = zeros(1, numel(dirScores));
NCW = zeros(1, numel(dirScores));
for numval = 1 : kfold
    
    %estraiamo gen e imp per l'iterazione
    [ind_gen, ind_imp] = compIndNfoldPerson(numGenuini, numImpostori, numInd, numSamples, kfold, numval);
    
    for k = 1 :numel(dirScores)
        NCW(k) = max(impostori(ind_imp, k)) - min(genuini(ind_gen, k));
        sumInvNCW = sumInvNCW + 1/NCW(k);
    end %for j = 1 :numel(dirScores)
    
    for k = 1 :numel(dirScores)
        weight(1, k) = (1/NCW(k))   /  (sumInvNCW)  ;
    end %for j = 1 :numel(dirScores)
    
    weightV = weightV + weight;
    
end %for g
weight = weightV / kfold;


% 
% y_gen = randsample(numel(genuini(:,1)), round(numel(genuini(:,1))*perc));
% y_imp = randsample(numel(impostori(:,1)), round(numel(impostori(:,1))*perc));
% param = VR_analysis(impostori(y_imp, :), genuini(y_gen, :));
% weight = cal_weight_fisher(1:numel(dirScores), param);

