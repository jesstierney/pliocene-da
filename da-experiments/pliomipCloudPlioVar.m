function[] = pliomipCloudPlioVar
%% Runs the data assimilation the full model prior, excluding COSMOS and unrealistic cloud forcing experiments
% ----------
%   Runs the DA with the full model prior as described in the paper. Excludes COSMOS
%   runs from PlioMIP2, and cloud runs with dGMST outside of [1 8]. Exports
%   reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates .mat files with the naming
%           scheme pliomip-cloud_<proxy network>_<uk seasonality>.mat
%       Reconstructions: Creates NetCDF files with the naming scheme
%           pliomip-cloud_<proxy network>_<uk seasonality>.nc    

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

% Remove non-PlioVar sites - read in table of sites to exclude
SiteExList = readtable("pliovarExcludeList.csv");
excludedSites = string(SiteExList.SiteName);
sites = gridfile('proxies').metadata.site(:,1);
SiteList = ~contains(sites,excludedSites);

% Run the DA with 24000 km localization
runDALocPV(tag, piRuns, plioRuns, 24000, SiteList);

% if you want to save deviations, use this, but note that this ONLY outputs
% .mat files and not NetCDF:
%runDALocDevPV(tag, piRuns, plioRuns, 24000, SiteList);

end