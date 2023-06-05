function[] = pliomipCloud
%% beok  Runs proxy network experiments using all available runs, excluding COSMOS and unrealistic cloud forcing experiments
% ----------
%   beok_0_8
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") using most available priors. Excludes COSMOS
%   runs from PlioMIP2, and cloud physics with dGMST outside of [0 8]. Runs
%   time-slice assmilations for the various experiments and exports
%   reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme beok-0-8_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           beok-0-8_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "pliomip-cloud";

% Get all runs
piRuns = parameters.preindustrialRuns.all;
plioRuns = parameters.plioceneRuns.all;

% Remove COSMOS
badRuns = parameters.excludeRuns;
remove = ismember(piRuns, badRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Calculate dGMST values for runs with altered cloud physics
cloudRuns = [parameters.plioceneRuns.Erfani2019;
             parameters.plioceneRuns.Burls2014];
piBackground = ["CESM1.2.2", "cheyctrl"];
season = parameters.dGMST.season;
deltas = dGMST(piBackground, cloudRuns, season);

% Removes runs outside of acceptable limits
limits = parameters.dGMST.limits;
badDeltas = deltas<limits(1) | deltas>limits(2);
badRuns = cloudRuns(badDeltas, :);
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

%choose to omit certain sites if you want
sites = gridfile('proxies').metadata.site(:,1);
sitestoDA = ~contains(sites,"ODP849") & ~contains(sites,"ODP984");

% Build reconstructions for different proxy network settings
runDALoc(tag, piRuns, plioRuns, 18000, sitestoDA);

end