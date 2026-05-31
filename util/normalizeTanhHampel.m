function [res] = normalizeTanhHampel(data, meanD, stdD)

res = 0.5 * (  tanh(  0.01 * ((data - meanD) / stdD) ) + 1 );