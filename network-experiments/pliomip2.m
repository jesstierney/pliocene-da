function[] = pliomip2
%% pliomip2  Runs proxy network experiments using PlioMIP2 runs, excluding COSMOS
% ----------
%   pliomip2
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") for priors selected from PlioMIP2 runs.
%   COSMOS runs are excluded from these priors. Runs time-slice assmilations 
%   for the various experiments and exports reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme pliomip2_<prior>_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           pliomip2_<proxy network>_<uk seasonality>.nc    

% Tag/label for the prior
tag = "pliomip2";

% Get PlioMIP2 runs
piMIP = parameters.preindustrialRuns.pliomip2;
plioMIP = parameters.plioceneRuns.pliomip2;

% Remove COSMOS
badRuns = parameters.excludeRuns;
remove = ismember(piMIP, badRuns, 'rows');
piMIP(remove,:) = [];
remove = ismember(plioMIP, badRuns, 'rows');
plioMIP(remove,:) = [];

% Build reconstructions for different proxy-network settings
runNetworkExperiments(tag, piMIP, plioMIP);

end