function [nwolves3, nsheep3, nparam] = VR_Fnorm(wolves, sheep, nparam)
%
% [nwolves3, nsheep3, nparam] = VR_Fnorm(wolves, sheep)
% will normalise according to the given data set
% [nwolves3, nsheep3] = VR_Fnorm(wolves, sheep, nparam)
% will normalise the data set according to the given parameter

%unit variance normalisation
if (nargin < 3),
    nparam{1} = VR_analysis(wolves, sheep);
end;
[nwolves, nsheep] = normalise_scores(wolves, sheep, nparam{1}.mu_all, nparam{1}.sigma_all);

%F-ratio normalisation
if (nargin < 3),
    nparam{2} = VR_analysis(nwolves, nsheep);
end;
[var_adj] = Fratio_norm(nparam{2});
denominator = 1 ./ var_adj;
shift = zeros(1, size(wolves,2));
[nwolves2, nsheep2] = normalise_scores(nwolves, nsheep, shift, denominator);

%shifting to centralise means
if (nargin < 3),
    nparam{3} = VR_analysis(nwolves2, nsheep2);
end;
ones_ = ones(1, size(wolves,2));
[nwolves3, nsheep3] = normalise_scores(nwolves2, nsheep2, nparam{3}.mu_C - 1, ones_);
nparam{4} = VR_analysis(nwolves3, nsheep3);
