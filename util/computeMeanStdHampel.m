function [dataH, meanD, stdD] = computeMeanStdHampel(data)

dataH = hampel(data);
meanD = mean(dataH);
stdD = std(dataH);