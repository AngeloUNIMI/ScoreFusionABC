function [ind_gen, ind_imp] = compIndNfoldPerson(numGenuini, numImpostori, numInd, numSamples, kfold, numval)

%numInd = 100;
%numSamples = 8;

%i confronti genuini per ogni sample sono a gruppi di numSamples-1
%numGenuini = numInd * numSamples * numSamples-1 (100 * 8 * 7 = 5600)
%numero confronti genuini per 1 individuo
numConfrontiGenPerInd = numSamples * (numSamples-1); %(8*7 = 56)
%numero confronti impostori per 1 individuo
numConfrontiImpPerInd = numSamples * (numInd-1) * numSamples;

%numero di individui per validazione
numIndPerVal = floor(numInd / kfold);

%calcoliamo indici per genuini
ind_rem_gen = ((numval-1) * numConfrontiGenPerInd * numIndPerVal) + 1 : numval * numConfrontiGenPerInd * numIndPerVal;
ind_gen = logical(1:numGenuini);
ind_gen(ind_rem_gen) = false;

%calcoliamo indici per impostori
ind_rem_imp = ((numval-1) * numConfrontiImpPerInd * numIndPerVal) + 1 : numval * numConfrontiImpPerInd * numIndPerVal;
ind_imp = logical(1:numImpostori);
ind_imp(ind_rem_imp) = false;



% clc,
% numval,
% numIndPerVal,
% numConfrontiGenPerInd
% ind_gen,
% pause
% clc
% numConfrontiImpPerInd
% ind_imp,
% pause,