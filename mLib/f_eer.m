function eer = f_eer(fratio)
% eer = f_eer(fratio)
% This function calculates EER from a given F-ratio
eer = 0.5 - 0.5 * erf( fratio ./sqrt(2));