function[uk, tex, mg] = globalR
%% parameters.globalR  Returns the global, conservative R values for the different proxy types
% ----------
%   [uk, tex, mg] = parameters.globalR
%   Returns the global, conservative R values for the various proxy types.
% ----------
%   Outputs:
%       uk (numeric scalar): The R value for UK'37 proxy records
%       tex (numeric scalar): The R value for TEX86 proxy records
%       mg (numeric scalar): The R value for Mg/Ca proxy records

% Conservatve, global R values (proxy error variances) for the different
% proxy types
uk = 0.0025;
tex = 0.0025;
mg = 0.0169;

end
