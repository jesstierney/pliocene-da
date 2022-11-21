function[runs] = cesm122
%% parameters.plioceneRuns.cesm122 Returns the metadata for all Pliocene-like runs from CESM1.2.2
% ----------
%   [runs] = parameters.plioceneRuns.cesm122
%   Returns the metadata for all Pliocene-like climate model runs generated
%   using CESM1.2.2. This includes runs from Erfani and Burls (2019), as well
%   as Ford et al. (2022). The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

runs = [
    "CESM1.2.2", "plio"
    "CESM1.2.2", "pliob17"
    parameters.plioceneRuns.Erfani2019
    ];

end