function[] = pliomip
%% pliomip  Runs proxy network experiments using runs from CESM2 and PlioMIP2, excluding COSMOS
% ----------
%   pliomip
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") using runs from CESM2 and PlioMIP2,
%   excluding COSMOS. Runs time-slice assmilations for the various 
%   experiments and exports reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme standard-prior_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           standard-prior_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "pliomip";

% Get CESM2 and PlioMIP2 runs
piRuns = parameters.preindustrialRuns.pliomip2;
plioRuns = [parameters.plioceneRuns.pliomip2;
            parameters.plioceneRuns.Feng2022];

% Remove COSMOS runs
removeRuns = parameters.excludeRuns;
remove = ismember(piRuns, removeRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, removeRuns, 'rows');
plioRuns(remove,:) = [];

% Build reconstructions for different proxy network settings
runDALoc(tag, piRuns, plioRuns, 3000);

end