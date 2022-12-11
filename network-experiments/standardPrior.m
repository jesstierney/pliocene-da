function[] = standardPrior
%% standardPrior  Runs proxy network experiments using all available runs from PlioMIP2 and CESM2, excluding COSMOS
% ----------
%   standardPrior
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") using most available runs from PlioMIP2 and
%   CESM2. Does not include COSMOS runs. Runs
%   time-slice assmilations for the various experiments and exports
%   reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme standard-prior_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           standard-prior_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "standard-prior";

% Get all runs
piRuns = parameters.preindustrialRuns.all;
plioRuns = parameters.plioceneRuns.all;

% Get metadata for COSMOS and cloud physics runs
cosmos = parameters.excludeRuns;
e19 = parameters.plioceneRuns.Erfani2019;
b14 = parameters.plioceneRuns.Burls2014;
removeRuns = [cosmos; e19; b14];

% Remove COSMOS and cloud physics runs
remove = ismember(piRuns, removeRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, removeRuns, 'rows');
plioRuns(remove,:) = [];

% Build reconstructions for different proxy network settings
runNetworkExperiments(tag, piRuns, plioRuns);

end