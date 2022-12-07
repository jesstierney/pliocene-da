function[runs] = excludeRuns
%% parameters.excludeRuns
% ----------
%   runs = parameters.excludeRuns
%   Returns metadata for runs that should be automatically excluded from all
%   priors.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): Run metadata for runs that should
%           be excluded from all priors. First column is the climate model,
%           second column is the experiment tag.

runs = [
    "COSMOS", "e280";
    "COSMOS", "eoi400";
    ];

end