function[runs] = all
%% parameters.preindustrialRuns.all  Returns the metadata for all pre-industrial runs
% ----------
%   [runs] = parameters.preindustrialRuns.all
%   Returns the metadata for all pre-industrial climate model runs. The 
%   output has one row per run and 2 columns. The first column lists the
%   climate model associated with each run, and the second column lists the
%   experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

%%%%%%%%%
runs = [
    parameters.preindustrialRuns.pliomip2
    parameters.preindustrialRuns.cesm122
    ];
%%%%%%%%%%

end