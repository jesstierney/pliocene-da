function[runs] = cloud
%% parameters.plioceneRuns.cesm  Returns the metadata for all Pliocene-like runs generated using CESM
% ----------
%   [runs] = parameters.plioceneRuns.cesm
%   Returns the metadata for all Pliocene-like climate model runs generated
%   using CESM. The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

runs = [
    parameters.plioceneRuns.cesm122
    parameters.plioceneRuns.Burls2014
    ];

end