function[runs] = cesm
%% parameters.preindustrialRuns.cesm  Returns the metadata for all pre-industrial runs generated using CESM
% ----------
%   [runs] = parameters.preindustrialRuns.cesm
%   Returns the metadata for all pre-industrial climate model runs generated
%   using CESM. The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

%%%%%%%%%
runs = [
    "CESM1.2",    "e280"
    "CESM2",      "e280"
    "CCSM4-NCAR",  "e280"
    "CCSM4-UoT",   "e280"
    parameters.preindustrialRuns.cesm122;
    ];
%%%%%%%%%%

end