function[runs] = Feng2022
%% parameters.plioceneRuns.Feng2022  Returns the metadata for all Pliocene-like runs from Feng et al., 2022
% ----------
%   [runs] = parameters.plioceneRuns.Feng2022
%   Returns the metadata for all Pliocene-like climate model runs generated
%   in Feng et al., 2022. The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

runs = [
    "CESM2",     "eo400new"
    "CESM2",     "pi400"
    ];

end