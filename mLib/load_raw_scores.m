function [wolves, sheep] = load_raw_scores(filename, working_col)
%
% [wolves, sheep] = load_raw_scores(filename, working_col)
% This function loads a file containing expert scores into the memory
% Input arg:
%   filename is the file containing the data with the following format
%       [score score score,..., class label]
%       score = score of expert column i
%       class_label = 1 means client access
%       class_label = 0 means impostor access
%   working_col is a vector containing the column index
%       if working_col is obmitted all the columns will be loaded
% Output arg:
%   wolves are a set of scores containing impostor accesses
%   sheep are a set of scores containg genuine accesses

dev = dlmread(filename,' ');
dev(1,:)=[];
col_class_label = size(dev,2);

if (nargin < 2),
  working_col = [1:col_class_label-1];
  fprintf('The following columns are used:');
  display(working_col);
end;
  
index_c = find(dev(:,col_class_label) >= 1);
index_i = find(dev(:,col_class_label) < 1);

wolves = dev(index_i,working_col);
sheep  = dev(index_c,working_col);

