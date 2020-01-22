function [scoresT_rem, confrT_rem, genImp, qualMean, qualAll, problem] = processScores(dirScores_train, dirQuality_train, dirResults, labelFig)
%functions that loads scores and quality values and performs preprocessin

%%%%%%%%%%%%%%%%%%%%%%%%
%load scores
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1, 'Loading scores...\n');

%loop on scores directory. Number of directories = number of biometric
%modalities
%remove parallel processing if needed (parfor -> for)
parfor s = 1 : numel(dirScores_train)
    
    %initialize data structures
    confr1 = [];
    score = [];
    
    %files containing the computed match scores (unimodal)
    allFiles = dir([dirScores_train{s} 'allFile*.dat']);
    for h = 1 : numel(allFiles)
        fprintf(1, '\t%s\n', allFiles(h).name);
        [v1, v3] = importAllFile([dirScores_train{s} allFiles(h).name]);
        confr1 = [confr1; v1];
        score = [score; str2double(v3)];
    end %for h
    
    %put data in cell array
    %number of cells = number of biometric modalities
    %comparison info
    confrT{s} = confr1;
    %scores
    scoresT{s} = score;
    
end %for s

%clear something
clear confr1 score v1 v3



%%%%%%%%%%%%%%%%%%%%%%%%
%comparison info (confrT) must be sorted
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1, 'Sorting...\n');

%clear and init
clear confrT_rem confrT_sorted I
confrT_remnum = cell(1, 2);
confrT_sorted = cell(1, 2);
I = cell(1, 2);

%remove some extra numbers
for s = 1 : numel(dirScores_train)
    for j = 1 : size(confrT{s},1)
        
        %display progress
        if mod(j, 100000) == 0
            fprintf(1, '\t%d / %d\n', j, size(confrT{s},1));
        end %if mod
        
        t1 = strrep(strrep(strrep(confrT{s}(j), '_', ''), ' - ', ''), '.dat', '');
        t2 = str2double(t1);
        confrT_remnum{s}(j,1) = t2;
    end %for j
end %for s

%clear something
clear confrT_merged

%sorting
for s = 1 : numel(dirScores_train)
    [confrT_sorted{s}, I{s}] = sort(confrT_remnum{s});
end %for s

%clear something
clear confrT_rem

%we use the computed indexes to sort the data
for s = 1 : numel(dirScores_train)
    confrT{s} = confrT{s}(I{s});
    scoresT{s} = scoresT{s}(I{s});
    confrT_remnum{s} = confrT_remnum{s}(I{s});
end %for s



%%%%%%%%%%%%%%%%%%%%%%%%
%data alignment
%(some matchers may have not obtained template for all samples
%scores corresponding to these samples must be removed by all data)
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1, 'Aligning...\n');

%get the matcher with the most elements
maxEls = -1;
for c = 1 : numel(dirScores_train)
    m = numel(confrT{c});
    if m > maxEls
        maxEls = m;
    end %if m
end %for c

%clear and init
clear v indexrem confrT_rem scoresT_rem
for k = 1 : numel(dirScores_train)
    v{k} = 1;
end %for k
confrT_rem = cell(maxEls, numel(dirScores_train));
scoresT_rem = cell(maxEls, numel(dirScores_train));
genImp = cell(maxEls, 1);
counter = 1;

%loop on data with comparison info
while 1
    
    %display progress
    if mod(v{1}, 50000) == 0
        fprintf(1, '\t%d\n', v{1});
    end %if mod v
    
    if sum([v{:}] > maxEls) >= 1 %if one of the indexes is outside the boundaries
        break; %exit the loop
    end %if sum
    
    %clear something
    clear riga;
    
    %loop on number of biometric modalities
    for c = 1 : numel(dirScores_train)
        
        %init
        %(riga = row)
        riga{c} = [];
        confr1 = confrT{c};
        score = scoresT{c};
        
        if v{c} <= numel(confr1)
            %ind1 - ind2 per ogni matcher c
            riga{c} = confr1{v{c}};
            score_temp{c} = score(v{c});
        else %if v
            riga{c} = ' - ';
            score_temp{c} = NaN;
        end %if v
        
    end %for c
    
    %different cells in the row (riga) must be equal
    %look for the string of first matcher in the others
    res = strcmp(riga{1}, riga);
    
    %if something is different
    if sum(res) ~= numel(dirScores_train)
        %do nothing
        
    else %if sum
        %is ok
        
        %save the comparison
        for c = 1 : numel(dirScores_train)
            confrT_rem{counter, c} = riga{c};
            scoresT_rem{counter, c} = score_temp{c};
        end %for c
        
        %check if genuine or impostor
        Sp = strsplit(riga{1}, ' - ');
        for r = 1 : numel(Sp)
            max = strsplit(Sp{r}, '_');
            Spp{r} = [max{1:end-1}];
        end %for r
        if strcmp(Spp{1}, Spp{2}) == 1
            %genuine
            genImp{counter} = 'gen';
        else %if strcmp
            %impostor
            genImp{counter} = 'imp';
        end %if strcmp
        
        counter = counter + 1;
        
    end %if sum
    
    %increment the counters of precedent comparisons
    %clear and init
    clear vec
    for k = 1 : numel(dirScores_train)
        vec{k} = num2str(confrT_remnum{k}(v{k}));
    end %for k
    
    %compare the values
    res2 = strcmp(vec{1}, vec);
    if sum(res2) == numel(dirScores_train)
        %sono uguali, incremento tutti
        for k = 1 : numel(dirScores_train)
            v{k} = v{k} + 1;
        end %for k
    else %if sum res2
        %if they are not equal, increment the smallest
        [minC, im] = min(str2double(vec));
        for k = im
            v{k} = v{k} + 1;
        end %for k
    end %if sum res2
    
    
    
end %for v

%remove data in excess
confrT_rem(counter:end, :) = [];
scoresT_rem(counter:end, :) = [];
genImp(counter:end, :) = [];



%%%%%%%%%%%%%%%%%%%%%%%%
%associate quality with score
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1, 'Loading qualities...\n');

%cleartsomething
clear qualMean qualAll

%init
qualMean = cell(size(scoresT_rem));
qualAll = cell(size(scoresT_rem, 1), size(scoresT_rem, 2) * 2);

%loop on scores
%(if needed, parfor -> for)
parfor p = 1 : size(scoresT_rem, 1)
    
    %display progress
    if mod(p, 50000) == 0
        fprintf(1, '\t%d\n', p);
    end %if mod v
    
    riga = confrT_rem{p, 1}; %the first part is equal to the second, I only take the first
    riga = strrep(riga, '.dat', '');
    C1 = strsplit(riga, ' - ');
    
    %init
    quality = [];
    scores = [];
    qualtemp = [];
    qualAll_temp = [];
    
    %loop on biometric modalities
    for k = 1 : numel(dirScores_train)
        
        %for each comparison there are 2 quality scores
        quality(1) = load([dirQuality_train{k} C1{1} '_quality.dat']);
        quality(2) = load([dirQuality_train{k} C1{2} '_quality.dat']);
        
        %if no quality is present, associate quality = 1
        if numel(quality(k)) == 0
            quality = [1 1];
        end %if numel
        
        %save quality of the comparison as the mean of the 2 qualities
        qualtemp = [qualtemp mean(quality)/100];
        
        %save all the qualities in the comparison
        qualAll_temp = [qualAll_temp quality/100];
        
    end %for k
    
    %mean quality of the 2 qualities in the comparison
    qualMean(p, :) = num2cell(qualtemp);
    
    %save all the qualities in the comparison
    qualAll(p, :) = num2cell(qualAll_temp);
    
end %for p



%%%%%%%%%%%%%%%%%%%%%%%%
%build data structure
%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1, 'Building data structure...\n');

%init
numScores = size(scoresT_rem, 1);
problem = zeros(numScores, numel(dirScores_train) + numel(dirScores_train) * 2);

%loop on biometric modalities
for k = 1 : numel(dirScores_train)
    problem(:,k) = [scoresT_rem{:, k}]';
end %for k
for k = 1 : numel(dirScores_train) * 2
    problem(:, numel(dirScores_train)+k) = [qualAll{:, k}]';
end %for k

%init
label = zeros(numScores, 1);

%create label 1/0
for i = 1 : numel(genImp)
    if strcmp(genImp{i}, 'gen') == 1
        label(i) = 1;
    else %if strcmp
        label(i) = 0;
    end %if strcmp
    
end %for i
problem(:, k+numel(dirScores_train)+1) = label;



%%%%%%%%%%%%%%%%%%%%%%%%
%plot
%%%%%%%%%%%%%%%%%%%%%%%%
fsfigure
step = 5;
%a = gscatter(problem(1:step:end,1), problem(1:step:end,2), label(1:step:end), [1 0 0; [0 0 1]], ['o', 'o'], 5, 'off', nomi_matchers{1}, nomi_matchers{2});
a = gscatter(problem(1:step:end,1), problem(1:step:end,2), label(1:step:end), [1 0 0; [0 0 1]], ['o', 'o'], 5, 'off', 'Face', 'Fingerprint');
set(a(1), 'MarkerFaceColor', 'r')
set(a(2), 'MarkerFaceColor', 'b')
set(a(1), 'MarkerEdgeColor', 'k')
set(a(2), 'MarkerEdgeColor', 'k')
set(gca,'FontSize', 14);
h_legend = legend('Impostors', 'Genuines');
set(h_legend,'FontSize',20);
saveas(gcf, [dirResults 'plot_scores_1_2_' labelFig '.jpg']);




