function [nwolves, nsheep] = normalise_scores(wolves, sheep, subtraction, division)

%normalise scores
n_w = size(wolves,1);
n_s = size(sheep,1);

wolves = wolves - repmat(subtraction, n_w,1);
wolves = wolves ./ repmat(division, n_w,1);

sheep = sheep - repmat(subtraction, n_s,1);
sheep = sheep ./ repmat(division, n_s,1);

nwolves = wolves;
nsheep = sheep;