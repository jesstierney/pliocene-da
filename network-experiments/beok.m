function[] = beok
%% beok  Runs proxy network experiments using all available runs, excluding COSMOS and unrealistic cloud forcing experiments
% ----------
%   beok
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") using most available priors. Excludes COSMOS
%   runs from PlioMIP2, and cloud physics with unreasonable dGMST values. Runs
%   time-slice assmilations for the various experiments and exports
%   reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme beok_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           beok_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "beok";

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

% Build reconstructions for different proxy network settings
runNetworkExperiments(tag, piRuns, plioRuns);

end