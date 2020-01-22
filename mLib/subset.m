function [tdata, ttype, left_data, left_type] = subset(data, type, n);
% [tdata ttype left_data left_type] = SUBSET(data, type, n)
% Get a subset of size n points from [data, type] into [tdata ttype].
% The rest of the points go into [left_data left_type].
% Preserves class portions, selects random points.

% Author: Pekka Paalanen <pekka.paalanen@lut.fi>

% gmmb_demo01.m,v 1.1 2004/02/19 16:40:49 paalanen Exp

tdata = zeros(n, size(data,2));
ttype = zeros(n, 1);
left_data = [];
left_type = [];

N = size(data,1);
if n>N
	tdata = data;
	ttype = type;
	return;
end

left_data = zeros(N-n, size(data,2));
left_type = zeros(N-n, 1);

done=0;
over=0;
e=0;
unkst = unique(type)';
for k = unkst
	cdata = data(type==k, :);
	cN = size(cdata,1);
	sn = min(round(n*cN/N), n-done);
	e = e + sn - n*cN/N;
	if e >= 1
		e = e-1;
		sn = sn -1;
	end
	if e <= -1
		e = e+1;
		sn = sn +1;
	end
	perm = randperm(cN);
	tdata((done+1):(done+sn), :) = cdata(perm(1:sn), :);
	left_data((over+1):(over+cN-sn), :) = cdata(perm((sn+1):cN), :);
	ttype((done+1):(done+sn), 1) = k;
	left_type((over+1):(over+cN-sn), :) = k;
	done = done + sn;
	over = over + cN - sn;
end

