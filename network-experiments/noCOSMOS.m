function[] = noCOSMOS
%% noCOSMOS  Runs proxy network experiments using PlioMIP2 runs, excluding COSMOS
% ----------
%   noCOSMOS
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") for priors selected from PlioMIP2 runs.
%   COSMOS runs are excluded from these priors. Runs time-slice assmilations 
%   for the various experiments and exports reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme no-cosmos_<prior>_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           no-cosmos_<proxy network>_<uk seasonality>.nc    

% Tag/label for the prior
tag = "no-cosmos";

% Get PlioMIP2 runs
piMIP = parameters.preindustrialRuns.pliomip2;
plioMIP = parameters.plioceneRuns.pliomip2;

% Remove COSMOS
cosmos = piMIP(:,1)=="COSMOS";
piMIP(cosmos,:) = [];
plioMIP(cosmos,:) = [];

% Build reconstructions for different proxy-network settings
runNetworkExperiments(tag, piMIP, plioMIP);

end