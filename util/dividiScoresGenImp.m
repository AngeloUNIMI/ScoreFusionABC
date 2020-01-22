function [genuini, impostori, numGenuini, numImpostori] = dividiScoresGenImp(scores, labels)


%dividiamo in genuini e impostori
genuini = -1 .* ones(1, numel(labels));
impostori = -1 .* ones(1, numel(labels));
counter_gen = 1;
counter_imp = 1;
for k = 1 : numel(labels)
    
    if strcmp(labels{k}, 'gen') == 1
        %genuino
        genuini(counter_gen) = scores(k);
        counter_gen = counter_gen + 1;
    else %if strcmp
        impostori(counter_imp) = scores(k);
        counter_imp = counter_imp + 1;
    end %if strcmp
    
        
end %for k

%rimuoviamo eccessi
genuini(counter_gen:end) = [];
impostori(counter_imp:end) = [];

%dimensioni
numGenuini = numel(genuini);
numImpostori = numel(impostori);