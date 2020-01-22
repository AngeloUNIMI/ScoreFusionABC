function [] = fusionLikelihoodRatio_wQual_crossT(scoresT_train_norm, scoresT_test_norm, qualMean_train_Norm, qualMean_test_Norm, ...
        genImp_train, genImp_test, dirScores_train, dirScores_test, dirResults, nomedb_train, nomedb_test, nomi_matchers, ...
        numGenuini_train, numGenuini_test, numImpostori_train, numImpostori_test, fidResults, plottaROCs, parM, numIter)




%variables
numMatchers = numel(dirScores_train);



%divisione score genuini e impostori

%train
genuini_train = zeros(numMatchers, numGenuini_train);
impostori_train = zeros(numMatchers, numImpostori_train);
for k = 1 : numMatchers
    [genuini_train(k,:), impostori_train(k,:)] = dividiScoresGenImp(scoresT_train_norm(:,k), genImp_train);
end %end for k

%test
genuini_test = zeros(numMatchers, numGenuini_test);
impostori_test = zeros(numMatchers, numImpostori_test);
for k = 1 : numMatchers
    [genuini_test(k,:), impostori_test(k,:)] = dividiScoresGenImp(scoresT_test_norm(:,k), genImp_test);
end %end for k


%divisione qualità genuini e impostori

%train
genuini_train_qual = zeros(numMatchers, numGenuini_train);
impostori_train_qual = zeros(numMatchers, numImpostori_train);
for k = 1 : numMatchers
    [genuini_train_qual(k,:), impostori_train_qual(k,:)] = dividiScoresGenImp(qualMean_train_Norm(:,k), genImp_train);
end %end for k

%test
genuini_test_qual = zeros(numMatchers, numGenuini_test);
impostori_test_qual = zeros(numMatchers, numImpostori_test);
for k = 1 : numMatchers
    [genuini_test_qual(k,:), impostori_test_qual(k,:)] = dividiScoresGenImp(qualMean_test_Norm(:,k), genImp_test);
end %end for k





%ciclo su iterazioni
%init
fpr = cell(numIter, 1);
fnr = cell(numIter, 1);
for ss = 1 : numIter
   
    
    fprintf(1, '\t\t\tGMM - iterazione N. %d\n', ss);
    

    %random sampling
    %train
    y_gen_train = randsample(numGenuini_train, parM.perc_gen * numGenuini_train);
    y_imp_train = randsample(numImpostori_train, parM.perc_imp * numImpostori_train);
    %test
    y_gen_test = randsample(numGenuini_test, parM.perc_gen * numGenuini_test);
    y_imp_test = randsample(numImpostori_test, parM.perc_imp * numImpostori_test);
    
    
 
    
    %estraiamo gli score di test
    genuini_test_sample = genuini_test;
    genuini_test_sample(:, y_gen_test) = [];
    numGenuini_test_sample = size(genuini_test_sample,2);
    impostori_test_sample = impostori_test;
    impostori_test_sample(:, y_imp_test) = [];
    numImpostori_test_sample = size(impostori_test_sample,2);
    scoresT_test = [genuini_test_sample impostori_test_sample]';
    numScores_test = size(scoresT_test, 1);
    
    %estraiamo le qualità di test
    genuini_test_sample_qual = genuini_test_qual;
    genuini_test_sample_qual(:, y_gen_test) = [];
    impostori_test_sample_qual = impostori_test_qual;
    impostori_test_sample_qual(:, y_imp_test) = [];
    qualT_test = [genuini_test_sample_qual impostori_test_sample_qual]';
    
    %labels corrispondenti
    genLabelTest = cellstr(repmat('gen', [numGenuini_test_sample 1]));
    impLabelTest = cellstr(repmat('imp', [numImpostori_test_sample 1]));
    genImpTest = [genLabelTest; impLabelTest];
    
    
    
    
    %facciamo tutto separatamente per ogni matcher e poi moltiplichiamo
    %init
    f_gen_all = ones(numScores_test, 1);
    f_imp_all = ones(numScores_test, 1);
    
    for ki = 1 : numMatchers
        
        fprintf(1, '\t\t\t\tMatcher N. %d\n', ki);
        
        %(train model) mixture components e probabilities
        fprintf(1, '\t\t\t\t\tCalcolo Mixture genuini\n');
        [bestk_gen, bestpp_gen, bestmu_gen, bestcov_gen, ~, ~] = ...
            mixtures4([genuini_train(ki, y_gen_train); genuini_train_qual(ki, y_gen_train)], parM.kmin, parM.kmax, parM.regularize, parM.th, parM.covoption, parM.verb, parM.plotta);
        fprintf(1, '\t\t\t\t\tCalcolo Mixture impostori\n');
        [bestk_imp, bestpp_imp, bestmu_imp, bestcov_imp, ~, ~] = ...
            mixtures4([impostori_train(ki, y_imp_train); impostori_train_qual(ki, y_imp_train)], parM.kmin, parM.kmax, parM.regularize, parM.th, parM.covoption, parM.verb, parM.plotta);
        
        
        
        
        
        
        
        %calcoliamo conditional joint densities
        fprintf(1, '\t\t\t\t\tCalcolo conditional joint densities\n');
        f_gen = zeros(numScores_test, 1);
        f_imp = zeros(numScores_test, 1);
        parfor m = 1 : numScores_test %ciclo sulle osservazioni
            
            if mod(m, 1e5) == 0
                fprintf(1, '\t\t\t\t\t\t%d\n', m);
            end %if mod v
            
            %osservazione
            oss = [scoresT_test(m, ki)'; qualT_test(m, ki)'];
            
            
            %sum su nj (numero componenti)
            sumnj = 0;
            for nj = 1 : bestk_gen
                muGen = bestmu_gen(:,nj);
                covGen = bestcov_gen(:,:,nj);
                %calcoliamo k-variate gaussian densities values
                %gdv_nj = (2*pi)^(-numMatchers/2) * det(covGen)^(-1/2)    *   exp(     -1/2*(oss - muGen)' * covGen^(-1) * (oss - muGen)   );
                gdv_nj =  (2*pi)^(-numMatchers/2) * det(covGen)^(-1/2)    *   exp(     -1/2*(oss - muGen)' * pinv(covGen) * (oss - muGen)   );
                %sommiamo
                weight = bestpp_gen(nj);
                sumnj = sumnj + weight * gdv_nj;
            end %for nk
            f_gen(m) = sumnj;
            
            sumnj = 0;
            for nj = 1 : bestk_imp
                %calcoliamo k-variate gaussian densities values
                muImp = bestmu_imp(:,nj);
                covImp = bestcov_imp(:,:,nj);
                %calcoliamo
                %gdv_nj = (2*pi)^(-numMatchers/2) * det(covImp)^(-1/2)    *   exp(     -1/2*(oss - muImp)' * covImp^(-1) * (oss - muImp)   );
                gdv_nj =  (2*pi)^(-numMatchers/2) * det(covImp)^(-1/2)    *   exp(     -1/2*(oss - muImp)' * pinv(covImp) * (oss - muImp)   );
                %sommiamo
                weight = bestpp_imp(nj);
                sumnj = sumnj + weight * gdv_nj;
                
            end %for nk
            f_imp(m) = sumnj;
            
            
        end %for m
        
        
        %evitiamo divisioni per 0
        impz = find(f_imp == 0);
        f_imp(impz) = f_imp(impz) + 0.0001;
        
        
        %moltiplichiamo
        f_gen_all = f_gen_all .* f_gen;
        f_imp_all = f_imp_all .* f_imp;
        
        
    end %end for ki (iterazione sui matcher)
    

    %ratio
    f_gen = f_gen_all;
    f_imp = f_imp_all;
    scores_lr = f_gen ./ f_imp;
    
   
    %dividiamo in genuini e impostori
    [gen_lr, imp_lr] = dividiScoresGenImp(scores_lr, genImpTest);
    
    
    %testiamo accuratezza biometrica
    [~, ~, ~, ~, ~, fpr{ss}, fnr{ss}] = indiciStatisticiIncertezzaVLFEAT(gen_lr, imp_lr, 'R', '', dirResults, 0);
    

end %for numIter


% %%%%
% assignin('base', 'scores_lr', scores_lr);
% assignin('base', 'f_gen', f_gen);
% assignin('base', 'f_imp', f_imp);
% %%%%



%mediamo fpr e fnr
fpr_mean = zeros(numScores_test, 1);
fnr_mean = zeros(numScores_test, 1);
for l = 1 : numIter
    fpr_mean = fpr_mean + fpr{l}(1:end-1)';
    fnr_mean = fnr_mean + fnr{l}(1:end-1)';
end %for l
fpr_mean  = fpr_mean ./ numIter;
fnr_mean  = fnr_mean ./ numIter;


%testiamo accuratezza biometrica e plottiamo
fprintf(1, '\tStatistiche\n');
labelTest = ['train_' nomedb_train '_test_'  nomedb_test  '_' [nomi_matchers{:}]];
[EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000] = ...
    indiciStatisticiIncertezza_fromFprFnr_VLFEAT(fpr_mean, fnr_mean, numGenuini_test, numImpostori_test, 'R', labelTest, dirResults, plottaROCs);


%salviamo
save([dirResults 'distr_qlratio.mat'], 'fpr', 'fnr', 'EER', 'zeroFMR');




%scrivo risultati su file
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