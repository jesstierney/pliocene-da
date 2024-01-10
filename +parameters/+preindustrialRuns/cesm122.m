function[runs] = cesm122
%% parameters.preindustrialRuns.cesm122  Returns the metadata for all pre-industrial runs generated using CESM1.2.2
% ----------
%   [runs] = parameters.preindustrialRuns.cesm122
%   Returns the metadata for all pre-industrial climate model runs generated
%   using CESM1.2.2. The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

%%%%%%%%%
runs = [
    "CESM1.2.2",  "preind"
    "CESM1.2.2",  "cheyctrl"
    "CESM1.0.4",  "piControl"
    ];
%%%%%%%%%%

end