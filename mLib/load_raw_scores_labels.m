function [wolves, sheep, model_wolves, model_sheep] = load_raw_scores_labels(filename, working_col, flag)
%
% [wolves, sheep, model_wolves, model_sheep] = load_raw_scores_labels(filename, working_col, dev)
% This function loads a file containing expert scores into the memory
% Input arg:
%   filename is the file containing the data with the following format
%       [prob_id model_id score score score,..., class label]
%       prob_id = the prob identity
%       model_id = the client model
%       score = score of expert column i
%       class_label = 1 means client access
%       class_label = 0 means impostor access
%   working_col is a vector containing the column index
%       if working_col is obmitted all the columns will be loaded
%   If flag is defined (1), filename is taken as a matrix
% Output arg:
%   wolves are a set of scores containing impostor accesses
%   sheep are a set of scores containg genuine accesses
%   model_wolves contains the model labels for the wolves data set
%   model_sheep contains the model labels for the sheep data set
%
%
% See also: load_raw_scores

if (nargin < 3),
    dev = dlmread(filename,' ');
else
    dev = filename;
end;
    
prob = dev(:,1);
model = dev(:,2);
dev(:,1:2)=[];

class_label = (prob == model);

if (nargin < 2),
  working_col = [1:size(dev,2)];
end;
fprintf('The following columns are used:');
display(working_col);
  
index_c = find(class_label == 1);
index_i = find(class_label == 0);

wolves = dev(index_i,working_col);
sheep  = dev(index_c,working_col);

model_wolves = model(index_i);
model_sheep = model(index_c);

display( sprintf( '%d samples loaded', size(wolves,1) + size(sheep,1)) );