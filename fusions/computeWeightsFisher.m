function weight = computeWeightsFisher(scoresT_norm, qualNorm, genImp, dirScores, numGenuini, numImpostori, numInd, numSamples, kfold)

genuini = zeros(numel(dirScores), numGenuini);
impostori = zeros(numel(dirScores), numImpostori);
for k = 1 : numel(dirScores)
    [genuini(k, :), impostori(k, :)] = dividiScoresGenImp(scoresT_norm(:,k) .* qualNorm(:,k), genImp);
end %for k
genuini = genuini';
impostori = impostori';

%10 fold validation per individui
weightV = zeros(1,2);
for numval = 1 : kfold
    [ind_gen, ind_imp] = compIndNfoldPerson(numGenuini, numImpostori, numInd, numSamples, kfold, numval);
    param = VR_analysis(impostori(ind_imp, :), genuini(ind_gen, :));
    weight = cal_weight_fisher(1:numel(dirScores), param);
    weightV = weightV + weight;
end %for g
weight = weightV / kfold;


% 
% y_gen = randsample(numel(genuini(:,1)), round(numel(genuini(:,1))*perc));
% y_imp = randsample(numel(impostori(:,1)), round(numel(impostori(:,1))*perc));
% param = VR_analysis(impostori(y_imp, :), genuini(y_gen, :));
% weight = cal_weight_fisher(1:numel(dirScores), param);

