function[uk, tex, mg] = osmanScaling
%% parameters.osmanScaling  Returns the scaling weights used for the Osman scaling
% ----------
%   [uk, tex, mg] = parameters.osmanScaling
%   Returns the scaling weights used to implement the Osman scaling for the
%   various proxy types. To implement the Osman scaling, divide the global,
%   conservative R values by these weights.
% ----------
%   Outputs:
%       uk (numeric scalar): The scaling weight for UK'37 R values 
%       tex (numeric scalar): The scaling weight for TEX86 R values
%       mg (numeric scalar): The scaling weight for Mg/Ca R values

% Scaling weights for the Osman scaling. The global, conservative R values
% (proxy error variances) should be divided by these values.
uk = 3.13;
tex = 1.36;
mg = 2.86;

end