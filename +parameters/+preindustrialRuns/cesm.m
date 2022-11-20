function[runs] = cesm
%% parameters.preindustrialRuns.cesm  Returns the names of all pre-industrial runs sourced from a CESM version
% ----------
%   [runs] = parameters.preindustrialRuns.cesm
%   Returns the names of all pre-industrial climate model runs sourced from
%   a CESM run. The output has one row per run and 2 columns. The first 
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each 
%           pre-industrial run.

%%%%%%%%%
runs = [
    "CESM1.0.5",  "e280"
    "CESM1.2",    "e280"
    "CESM2",      "e280"
    "CESM1.2.2",  "PreInd"
    "CESM1.2.2",  "cheyctrl"
    ];
%%%%%%%%%%

end