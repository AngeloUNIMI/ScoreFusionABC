function [] = fusionLikelihoodRatio_wQual(scoresT_norm, qualMeanNorm, genImp, dirScores, dirResults, nomedb, matchers_names, ...
    numGenuini, numImpostori, fidResults, plottaROCs, parM, numIter)

%K. Nandakumar, Y. Chen, S. C. Dass and A. Jain,
%"Likelihood Ratio-Based Biometric Score Fusion,"
%in IEEE Transactions on Pattern Analysis and Machine Intelligence,
%vol. 30, no. 2, pp. 342-347, Feb. 2008.

%variables
numMatchers = numel(dirScores);


%divide scores in genuine and impostors
genuins = zeros(numMatchers, numGenuini);
impostors = zeros(numMatchers, numImpostori);
for k = 1 : numMatchers
    [genuins(k,:), impostors(k,:)] = dividiScoresGenImp(scoresT_norm(:,k), genImp);
end %end for k


%divide qualities in genuine and impostors
genuins_qual = zeros(numMatchers, numGenuini);
impostors_qual = zeros(numMatchers, numImpostori);
for k = 1 : numMatchers
    [genuins_qual(k,:), impostors_qual(k,:)] = dividiScoresGenImp(qualMeanNorm(:,k), genImp);
end %end for k


%loop on iterations (repeated multiple times and averaged)
%init
fpr = cell(numIter, 1);
fnr = cell(numIter, 1);
for ss = 1 : numIter
   
    %display progress
    fprintf(1, '\t\t\tGMM - iterazione N. %d\n', ss);
    
    
    %random sampling
    y_gen_train = randsample(numGenuini, parM.perc_gen * numGenuini);
    y_imp_train = randsample(numImpostori, parM.perc_imp * numImpostori);
    
    
    %extract test scores
    genuini_test = genuins;
    genuini_test(:, y_gen_train) = [];
    numGenuini_test = size(genuini_test,2);
    impostori_test = impostors;
    impostori_test(:, y_imp_train) = [];
    numImpostori_test = size(impostori_test,2);
    scoresT_test = [genuini_test impostori_test]';
    numScores_test = size(scoresT_test, 1);
    
    %extract test qualities
    genuini_qual_test = genuins_qual;
    genuini_qual_test(:, y_gen_train) = [];
    impostori_qual_test = impostors_qual;
    impostori_qual_test(:, y_imp_train) = [];
    qualT_test = [genuini_qual_test impostori_qual_test]';
    
    %extract corresponding labels
    genLabelTest = cellstr(repmat('gen', [numGenuini_test 1]));
    impLabelTest = cellstr(repmat('imp', [numImpostori_test 1]));
    genImpTest = [genLabelTest; impLabelTest];
    
    
    
    
    %with qualities, computation is performed independently for each
    %matcher and then multiplied
    %init
    f_gen_all = ones(numScores_test, 1);
    f_imp_all = ones(numScores_test, 1);
    
    %loop on number of biometric modalities
    for ki = 1 : numMatchers
        
        %display progress
        fprintf(1, '\t\t\t\tMatcher N. %d\n', ki);
        
        %computation of mixture components (GMM) and probabilities
        %for genuines
        fprintf(1, '\t\t\t\tComputing Mixture of genuines\n');
        [bestk_gen, bestpp_gen, bestmu_gen, bestcov_gen, ~, ~] = ...
            mixtures4([genuins(ki, y_gen_train); genuins_qual(ki, y_gen_train)], parM.kmin, parM.kmax, parM.regularize, parM.th, parM.covoption, parM.verb, parM.plotta);
        %for impostors
        fprintf(1, '\t\t\t\tComputing Mixture of impostors\n');
        [bestk_imp, bestpp_imp, bestmu_imp, bestcov_imp, ~, ~] = ...
            mixtures4([impostors(ki, y_imp_train); impostors_qual(ki, y_imp_train)], parM.kmin, parM.kmax, parM.regularize, parM.th, parM.covoption, parM.verb, parM.plotta);
    
        
        %computation of conditional joint densities
        fprintf(1, '\t\t\t\tComputation of conditional joint densities\n');
        
        %init
        f_gen = zeros(numScores_test, 1);
        f_imp = zeros(numScores_test, 1);
        
        %loop on observations (observation: vector of scores obtained from the
        %different biometric modalities)
        %(if necessary parfor -> for)
        parfor m = 1 : numScores_test
            
            %display progress
            if mod(m, 1e5) == 0
                fprintf(1, '\t\t\t\t\t\t%d\n', m);
            end %if mod v
            
            
            %select observation
            oss = [scoresT_test(m, ki)'; qualT_test(m, ki)'];
              
            
            %(name of variables should be similar to the paper)
            %sum on nj (number of components)
            sumnj = 0;
            %analysis of components for genuine scores
            for nj = 1 : bestk_gen
                %computation of k-variate gaussian densities values
                muGen = bestmu_gen(:,nj);
                covGen = bestcov_gen(:,:,nj);
                %gdv_nj = (2*pi)^(-numMatchers/2) * det(covGen)^(-1/2)    *   exp(     -1/2*(oss - muGen)' * covGen^(-1) * (oss - muGen)   );
                gdv_nj =  (2*pi)^(-numMatchers/2) * det(covGen)^(-1/2)    *   exp(     -1/2*(oss - muGen)' * pinv(covGen) * (oss - muGen)   );
                %sommiamo
                weight = bestpp_gen(nj);
                sumnj = sumnj + weight * gdv_nj;        
            end %for nk
            f_gen(m) = sumnj;


            %analysis of components for impostor scores
            sumnj = 0;
            for nj = 1 : bestk_imp
                %computation of k-variate gaussian densities values
                muImp = bestmu_imp(:,nj);
                covImp = bestcov_imp(:,:,nj);
                %gdv_nj = (2*pi)^(-numMatchers/2) * det(covImp)^(-1/2)    *   exp(     -1/2*(oss - muImp)' * covImp^(-1) * (oss - muImp)   );
                gdv_nj =  (2*pi)^(-numMatchers/2) * det(covImp)^(-1/2)    *   exp(     -1/2*(oss - muImp)' * pinv(covImp) * (oss - muImp)   );
                %sum
                weight = bestpp_imp(nj);
                sumnj = sumnj + weight * gdv_nj;  
            end %for nk
            f_imp(m) = sumnj;
            
            
        end %for m
        
        
        %avoid dividing by 0
        impz = find(f_imp == 0);
        f_imp(impz) = f_imp(impz) + 0.0001;
        
        
        %multiply likelihood ratio
        f_gen_all = f_gen_all .* f_gen;
        f_imp_all = f_imp_all .* f_imp;
        
        
    end %end for ki
    

    %final likelihood ratio (for each iteration)
    f_gen = f_gen_all;
    f_imp = f_imp_all;
    scores_lr = f_gen ./ f_imp;
    
   
    %divide in genuine and impostors
    [gen_lr, imp_lr] = dividiScoresGenImp(scores_lr, genImpTest);
    
    
    %fpr and fnr for each iteration
    [~, ~, ~, ~, ~, fpr{ss}, fnr{ss}, eer_threshold, fmr1000_threshold] = indiciStatisticiIncertezzaVLFEAT(gen_lr, imp_lr, 'R', '', dirResults, 0);
    

end %for numIter


%compute average fpr e fnr
fpr_mean = zeros(numScores_test, 1);
fnr_mean = zeros(numScores_test, 1);
for l = 1 : numIter
    fpr_mean = fpr_mean + fpr{l}(1:end-1)';
    fnr_mean = fnr_mean + fnr{l}(1:end-1)';
end %for l
fpr_mean  = fpr_mean ./ numIter;
fnr_mean  = fnr_mean ./ numIter;


%final biometric error measures
fprintf(1, '\tStatistics\n');
labelTest = [nomedb '_QLR_' [matchers_names{:}]];
[EER, deltaFMR_EER, deltaFNMR_EER, zeroFMR, FMR1000] = ...
    indiciStatisticiIncertezza_fromFprFnr_VLFEAT(fpr_mean, fnr_mean, numGenuini_test, numImpostori_test, 'R', labelTest, dirResults, plottaROCs);


%save data
save([dirResults 'distr_qlratio.mat'], 'fpr', 'fnr', 'EER', 'zeroFMR');

%print results on file
fprintf(fidResults, '%s\r\n', labelTest);
fprintf(fidResults, 'EER (%%): %f\r\n', EER*100);
fprintf(fidResults, 'Threshold EER: %f\r\n', eer_threshold);
fprintf(fidResults, 'deltaFMR_EER (%%): %f\r\n', deltaFMR_EER*100);
fprintf(fidResults, 'deltaFNMR_EER (%%): %f\r\n', deltaFNMR_EER*100);
fprintf(fidResults, 'ZeroFMR (%%): %f\r\n', zeroFMR*100);
fprintf(fidResults, 'FMR_1000 (%%): %f\r\n', FMR1000*100);
fprintf(fidResults, 'Threshold FMR_1000: %f\r\n', fmr1000_threshold);
fprintf(fidResults, '\r\n\r\n');






%%%%%%%%%
pause(1)
%%%%%%%%%


