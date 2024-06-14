function[] = pliomip
%% pliomip  Runs the DA using runs from PlioMIP2, excluding COSMOS
% ----------
%   pliomip
%   Runs the DA using runs from PlioMIP2 only,
%   excluding COSMOS. 
% ----------
%   Outputs:
%       Assimilated time slices: Creates .mat files with the naming
%           scheme pliomip_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates NetCDF files with the naming scheme
%           pliomip_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "pliomip";

% Get PlioMIP2 runs
piRuns = parameters.preindustrialRuns.pliomip2;
plioRuns = parameters.plioceneRuns.pliomip2;

% Remove COSMOS runs
removeRuns = parameters.excludeRuns;
remove = ismember(piRuns, removeRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, removeRuns, 'rows');
plioRuns(remove,:) = [];

% Run the DA with 24000 km localization
runDALoc(tag, piRuns, plioRuns, 24000);

% if you want to run the DA w/o localization you would need this command:
% runDAnoLoc(tag, piRuns, plioRuns);

% if you want to save deviations, use this, but note that this ONLY outputs
% .mat files and not NetCDF:
% runDALocDev(tag, piRuns, plioRuns, 24000);

end