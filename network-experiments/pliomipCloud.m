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
cloudRuns1 = parameters.plioceneRuns.Erfani2019;
cloudRuns2 = parameters.plioceneRuns.Burls2014;
piBackground1 = ["CESM1.2.2", "cheyctrl"];
piBackground2 = ["CESM1.0.4", "piControl"];
season = parameters.dGMST.season;
deltas1 = dGMST(piBackground1, cloudRuns1, season);
deltas2 = dGMST(piBackground2, cloudRuns2, season);

% Removes runs outside of acceptable limits
limits = parameters.dGMST.limits;
badDeltas1 = deltas1<limits(1) | deltas1>limits(2);
badDeltas2 = deltas2<limits(1) | deltas2>limits(2);
badRuns = [cloudRuns1(badDeltas1, :); cloudRuns2(badDeltas2, :)];
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

%choose to omit certain sites if you want
%sites = gridfile('proxies').metadata.site(:,1);
%sitestoDA = ~contains(sites,"ODP849") & ~contains(sites,"ODP984");

% Build reconstructions for different proxy network settings
runDALoc(tag, piRuns, plioRuns, 24000);

end