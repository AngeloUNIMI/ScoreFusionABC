function norm_dev = ppndf (cum_prob)
% function ppndf (prob)
%
% The input to this function is a cumulative probability.
% The output from this function is the Normal Gaussian
% deviate that corresponds to that probability.
% For example:
%    INPUT       OUTPUT
%  (cum_prob)  (norm_dev)
%    0.001  -3.090
%    0.01   -2.326
%    0.1    -1.282
%    0.5     0.0
%    0.9     1.282
%    0.99    2.326
%    0.999   3.090

 SPLIT = 0.42;

 A0 =   2.5066282388;
 A1 = -18.6150006252;
 A2 =  41.3911977353;
 A3 = -25.4410604963;
 B1 =  -8.4735109309;
 B2 =  23.0833674374;
 B3 = -21.0622410182;
 B4 =   3.1308290983;
 C0 =  -2.7871893113;
 C1 =  -2.2979647913;
 C2 =   4.8501412713;
 C3 =   2.3212127685;
 D1 =   3.5438892476;
 D2 =   1.6370678189;

 [Nrows Ncols] = size(cum_prob);
 norm_dev = zeros(Nrows, Ncols); % preallocate norm_dev for speed
 for irow=1:Nrows
 for icol=1:Ncols

     prob = cum_prob(irow, icol);
     if (prob >= 1.0)
	prob = 1-eps;
     elseif (prob <= 0.0)
	prob = eps;
     end

     q = prob - 0.5;
     if (abs(prob-0.5) <= SPLIT)
	r = q * q;
	pf = q * (((A3 * r + A2) * r + A1) * r + A0);
        pf = pf / ((((B4 * r + B3) * r + B2) * r + B1) * r + 1.0);

     else
         if (q>0.0)
	     r = 1.0-prob;
	 else
	     r = prob;
         end

         r = sqrt ((-1.0) * log (r));
         pf = (((C3 * r + C2) * r + C1) * r + C0);
         pf = pf / ((D2 * r + D1) * r + 1.0);
 	 if (q < 0)
	    pf = pf * (-1.0);
         end
     end
     norm_dev(irow, icol) = pf;
 end
 end