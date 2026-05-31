%SCRIPT THAT LOADS THE SCORES AND PERFORMS SCORE-LEVEL FUSION
%CONSIDERING ALSO QUALITY SCORES
%with Cross-Training (privacy-compliant training)


clc
close all
clear variables
fclose('all');
warning('off', 'all')



%--------------------------------------------------------------------------
%paths
addpath('./util');
addpath('./biometricUtil');
addpath('./mLib');
addpath('./fusions');
addpath('./mixturecode2');
addpath(genpath('./calcoloROC'));
run('./calcoloROC/vlfeat/vlfeat-0.9.20/toolbox/vl_setup')



%--------------------------------------------------------------------------
%parameters
plotROCs = 1;
kfold = 10;
numInd = 100;
numSamples = 8;
numIter = 10; %%%%

%parameters mixture code
parM.kmin = 1;
parM.kmax = 10;
parM.regularize = 0;
parM.th = 1e-2; %1e-2
parM.covoption = 0;
parM.perc_gen = 0.5; %%%%
parM.perc_imp = 0.5; %%%%
parM.verb = 0;
parM.plotta = 0;



%--------------------------------------------------------------------------
%database parameters

%db name
%test scenario 1
dbname_train = '(Sim DB ABC 1)';
dbname_test =  '(Sim DB ABC 1)';

%test scenario 2
% dbname_train = '(Sim DB ABC 2)';
% dbname_test =  '(Sim DB ABC 2)';

%privacy-aware evaluation 1
% dbname_train = '(Sim DB ABC 1)';
% dbname_test =  '(Sim DB ABC 2)';

%privacy-aware evaluation 2
% dbname_train = '(Sim DB ABC 2)';
% dbname_test =  '(Sim DB ABC 1)';


%directory containing the scores
%these files must be computed using the respective SDKs
%before using this script
dirScores_train = { ...
    ['./DATA_scores/Cognitec_face\' dbname_train ' (Face)\'] ...
    ['./DATA_scores/Dermalog_fingerprint\' dbname_train ' (Fingerprint)\'] ...
    };
dirScores_test = { ...
    ['./DATA_scores/Cognitec_face\' dbname_test ' (Face)\'] ...
    ['./DATA_scores/Dermalog_fingerprint\' dbname_test ' (Fingerprint)\'] ...
    };

%directory containing the qualities
%these files must be computed using the respective SDKs
%before using this script
dirQuality_train = { ...
    ['./DATA_qualities/Cognitec_face\' dbname_train ' (Face)\'] ...
    ['./DATA_qualities/Dermalog_fingerprint\' dbname_train ' (Fingerprint)\'] ...
    };
dirQuality_test = { ...
    ['./DATA_qualities/Cognitec_face\' dbname_test ' (Face)\'] ...
    ['./DATA_qualities/Dermalog_fingerprint\' dbname_test ' (Fingerprint)\'] ...
    };

%name of used matchers (for result plotting) (CT: Cognitec; DL: Dermalog; NT: Neurotechnology)
matchers_names = {'CT (Face)', ' DL (Fingerprint)'};

%directory of results
dirResults = ['./Results_WSQ/train_' dbname_train '_test_'  dbname_test  '/' [matchers_names{:}] '/']; mkdir(dirResults);



%--------------------------------------------------------------------------
%data preprocessing

%training data
%check if scores have already been preprocessed and saved
if exist([dirResults 'scores_train_' [matchers_names{:}] '.mat'], 'file') ~= 2
    
    %load scores and alignment
    fprintf(1, 'Loading score training\n');
    [scoresT_train_rem, confrT_train_rem, genImp_train, qualMean_train, qualAll_train, problem_train] = processScores(dirScores_train, dirQuality_train, dirResults, 'train');
    
    %save preprocessed data
    save([dirResults 'scores_train_' [matchers_names{:}] '.mat'], ...
        'scoresT_train_rem', 'confrT_train_rem', 'genImp_train', 'matchers_names', 'qualMean_train', 'qualAll_train', 'problem_train');
    
else %if exist([dirResults 'scores_train_' [matchers_names{:}] '.mat'], 'file') ~= 2
    
    %if scores are already preprocessed and saved, load file
    fprintf(1, 'Training scores already preprocessed\n');
    load([dirResults 'scores_train_' [matchers_names{:}] '.mat']);
    
end %if exist([dirResults 'scores_train_' [matchers_names{:}] '.mat'], 'file') ~= 2


%test data
%check if scores have already been preprocessed and saved
if exist([dirResults 'scores_test_' [matchers_names{:}] '.mat'], 'file') ~= 2
    
    %load scores and alignment
    fprintf(1, 'Loading score testing\n');
    [scoresT_test_rem, confrT_test_rem, genImp_test, qualMean_test, qualAll_test, problem_test] = processScores(dirScores_test, dirQuality_test, dirResults, 'test');
    
    %save preprocessed data
    save([dirResults 'scores_test_' [matchers_names{:}] '.mat'], ...
        'scoresT_test_rem', 'confrT_test_rem', 'genImp_test', 'matchers_names', 'qualMean_test', 'qualAll_test', 'problem_test');
    
else %if exist([dirResults 'scores_train_' [matchers_names{:}] '.mat'], 'file') ~= 2
    
    %if scores are already preprocessed and saved, load file
    fprintf(1, 'Score testing already processed\n');
    load([dirResults 'scores_test_' [matchers_names{:}] '.mat']);
    
end %if exist([dirResults 'scores_train_' [matchers_names{:}] '.mat'], 'file') ~= 2



%--------------------------------------------------------------------------
%score fusion
fprintf(1, 'Fusion...\n');

%init train data
clear normData scoresT_train_norm qualMean_train_Norm qualAll_train_Norm
scoresT_train_norm = zeros(size(scoresT_train_rem,1), numel(dirScores_train));
qualMean_train_Norm = zeros(size(scoresT_train_rem,1), numel(dirScores_train));
qualAll_train_Norm = zeros(size(scoresT_train_rem,1), numel(dirScores_train)*2);

%init test data
clear normData scoresT_test_norm qualMean_test_Norm qualAll_test_Norm
scoresT_test_norm = zeros(size(scoresT_test_rem,1), numel(dirScores_test));
qualMean_test_Norm = zeros(size(scoresT_test_rem,1), numel(dirScores_test));
qualAll_test_Norm = zeros(size(scoresT_test_rem,1), numel(dirScores_test)*2);


%loop on normalizations (0=no normalization, 1=minmax, 2=z-score)
%(probably z-score normalization should be performed by learning the
%parameters from a subset and applying on the remaining subset)
for normData = [0 1 2]
    
    %make directgory
    dirResultsNorm = [dirResults 'n' num2str(normData) '/'];
    mkdir(dirResultsNorm);
    %open file with results
    fidResults = fopen([dirResultsNorm 'results_score_fusion_norm_' num2str(normData) '.dat'], 'w');
    fprintf(fidResults, 'Normalization: \r\n');
    
    %normalization
    switch normData
        
        case 0
            fprintf(1, '\tNo normalization...\n');
            fprintf(fidResults, 'No normalization\r\n');
            fprintf(fidResults, '\r\n\r\n');
            
            %train
            for k = 1 : numel(dirScores_train)
                scoresT_train_norm(:, k) = [scoresT_train_rem{:, k}]';
                qualMean_train_Norm(:, k) = [qualMean_train{:, k}]';
            end %for k
            for k = 1 : numel(dirScores_train) * 2
                qualAll_train_Norm(:, k) = [qualAll_train{:, k}]';
            end %for k
            
            %test
            for k = 1 : numel(dirScores_test)
                scoresT_test_norm(:, k) = [scoresT_test_rem{:, k}]';
                qualMean_test_Norm(:, k) = [qualMean_test{:, k}]';
            end %for k
            for k = 1 : numel(dirScores_test) * 2
                qualAll_test_Norm(:, k) = [qualAll_test{:, k}]';
            end %for k
            
            
        case 1
            fprintf(1, '\tMin-Max normalization...\n');
            fprintf(fidResults, 'Min-Max\r\n');
            fprintf(fidResults, '\r\n\r\n');
            
            %train
            for k = 1 : numel(dirScores_train)
                scoresT_train_norm(:, k) = normalizeMinMax([scoresT_train_rem{:, k}]);
                qualMean_train_Norm(:, k) = normalizeMinMax([qualMean_train{:, k}]);
            end %for k
            for k = 1 : numel(dirScores_train) * 2
                qualAll_train_Norm(:, k) = normalizeMinMax([qualAll_train{:, k}]);
            end %for k
            
            %test
            for k = 1 : numel(dirScores_test)
                scoresT_test_norm(:, k) = normalizeMinMax([scoresT_test_rem{:, k}]);
                qualMean_test_Norm(:, k) = normalizeMinMax([qualMean_test{:, k}]);
            end %for k
            for k = 1 : numel(dirScores_test) * 2
                qualAll_test_Norm(:, k) = normalizeMinMax([qualAll_test{:, k}]);
            end %for k
            
            
            
            
        case 2
            fprintf(1, '\tZ-score normalization...\n');
            fprintf(fidResults, 'Z-Score\r\n');
            fprintf(fidResults, '\r\n\r\n');
            
            %train
            for k = 1 : numel(dirScores_train)
                scoresT_train_norm(:, k) = normalizeZScore([scoresT_train_rem{:, k}]);
                qualMean_train_Norm(:, k) = normalizeZScore([qualMean_train{:, k}]);
            end %for k
            for k = 1 : numel(dirScores_train) * 2
                qualAll_train_Norm(:, k) = normalizeZScore([qualAll_train{:, k}]);
            end %for k
            
            %test
            for k = 1 : numel(dirScores_test)
                scoresT_test_norm(:, k) = normalizeZScore([scoresT_test_rem{:, k}]);
                qualMean_test_Norm(:, k) = normalizeZScore([qualMean_test{:, k}]);
            end %for k
            for k = 1 : numel(dirScores_test) * 2
                qualAll_test_Norm(:, k) = normalizeZScore([qualAll_test{:, k}]);
            end %for k
            
            
    end %switch normdata
    
    
    
    %divide in genuine e impostors

    %train
    clear genuini_train impostori_train
    genuines_train = cell(numel(dirScores_train,1));
    impostors_train = cell(numel(dirScores_train,1));
    for k = 1 : numel(dirScores_train)
        [genuines_train{k}, impostors_train{k}] = dividiScoresGenImp(scoresT_train_norm(:,k), genImp_train);
    end
    numGenuines_train = numel(genuines_train{1});
    numImpostors_train = numel(impostors_train{1});
    
    %test
    clear genuini_test impostori_test
    genuines_test = cell(numel(dirScores_test,1));
    impostors_test = cell(numel(dirScores_test,1));
    for k = 1 : numel(dirScores_test)
        [genuines_test{k}, impostors_test{k}] = dividiScoresGenImp(scoresT_test_norm(:,k), genImp_test);
    end
    numGenuines_test = numel(genuines_test{1});
    numImpostors_test = numel(impostors_test{1});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %results of single separated matchers
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tSingle biometrics\n');
    
    %init
    EER_single = zeros(1, numel(dirScores_train));
    deltaFMR_EER_single = zeros(1, numel(dirScores_train));
    deltaFNMR_EER_single = zeros(1, numel(dirScores_train));
    zeroFMR_single = zeros(1, numel(dirScores_train));
    FMR1000_single = zeros(1, numel(dirScores_train));
    eer_single_threshold = zeros(1, numel(dirScores_train));
    
    %loop on biometric modalities
    for k = 1 : numel(dirScores_train)
        
        %init
        saveGenImp(genuines_train{k}, impostors_train{k}, [dirResultsNorm 'distr_' matchers_names{k} '.mat']);
        label_train = [dbname_train '_' [matchers_names{k}]];
        
        %biometric error measures
        [EER_single(k), deltaFMR_EER_single(k), deltaFNMR_EER_single(k), zeroFMR_single(k), FMR1000_single(k), ~, ~, eer_single_threshold(k)] = ...
            indiciStatisticiIncertezzaVLFEAT(genuines_train{k}, impostors_train{k}, 'R', label_train, dirResultsNorm, plotROCs);
        
        %print results on file
        fprintf(fidResults, '%s\r\n', label_train);
        fprintf(fidResults, 'EER (%%): %f\r\n', EER_single(k)*100);
        fprintf(fidResults, 'deltaFMR_EER (%%): %f\r\n', deltaFMR_EER_single(k)*100);
        fprintf(fidResults, 'deltaFNMR_EER (%%): %f\r\n', deltaFNMR_EER_single(k)*100);
        fprintf(fidResults, 'ZeroFMR (%%): %f\r\n', zeroFMR_single(k)*100);
        fprintf(fidResults, 'FMR_1000 (%%): %f\r\n', FMR1000_single(k)*100);
        fprintf(fidResults, '\r\n\r\n');
        
    end %for k
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using SIMPLE SUM
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tSimple sum\n');
    fusionSimpleSum(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using PRODUCT
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tProduct\n');
    fusionProduct(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using MAX
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tMax\n');
    fusionMax(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using MIN
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tMin\n');
    fusionMin(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using WEIGHTED SUM
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tWeighted sum Fisher\n');
    fusionWeightedSum(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, ...
        numGenuines_train, numImpostors_train, numInd, numSamples, kfold, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using WEIGHTED SUM ICPR 2010
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tWeighted sum ICPR 2010\n');
    fusionWeightedSumICPR2010(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, ...
        numGenuines_train, numImpostors_train, numInd, numSamples, kfold, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using WEIGHTED SUM MEW
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tWeighted sum MEW\n');
    fusionWeightedSumMEW(scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, dbname_train, matchers_names, ...
        numGenuines_train, numImpostors_train, numInd, numSamples, kfold, fidResults, plotROCs);
    close all
    pause(1)
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using WEIGHTED SUM OLD
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tWeighted sum OLD\n');
    fusionWeightedSumOLD(EER_single, eer_single_threshold, scoresT_train_norm, ones(size(scoresT_train_norm)), genImp_train, dirScores_train, dirResultsNorm, normData, ...
        dbname_train, matchers_names, numGenuines_train, numImpostors_train, numInd, numSamples, kfold, fidResults, plotROCs);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using LIKELIHOOD RATIO
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tLikelihood ratio\n');
    fusionLikelihoodRatio(scoresT_train_norm, genImp_train, dirScores_train, dirResultsNorm, dbname_train, matchers_names, ...
        numGenuines_train, numImpostors_train, fidResults, plotROCs, parM, numIter);
    close all
    pause(1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %fusion using QUALITY-BASED LIKELIHOOD RATIO
    %with Cross-Training (privacy-compliant training)
    %if different scenarios are chosen for train and test
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1,'\t\tCross-training quality-based likelihood ratio\n');
    fusionLikelihoodRatio_wQual_crossT(scoresT_train_norm, scoresT_test_norm, qualMean_train_Norm, qualMean_test_Norm, ...
        genImp_train, genImp_test, dirScores_train, dirScores_test, dirResultsNorm, dbname_train, dbname_test, matchers_names, ...
        numGenuines_train, numGenuines_test, numImpostors_train, numImpostors_test, fidResults, plotROCs, parM, numIter);
    
    
    %close results file
    close all
    pause(1)
    fclose('all');
    
    
  
end %for normData



%%%%%%%%%%%%%%%%%%%%%%%%
%close every file - to be sure
%%%%%%%%%%%%%%%%%%%%%%%%
fclose('all');




