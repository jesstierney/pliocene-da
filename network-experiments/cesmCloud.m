function[] = cesmCloud
%% cesmCloud  Runs proxy network experiments using CESM cloud runs, excluding cloud runs with unrealistic dGMST
% ----------
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") for priors selected from CESM runs. Cloud
%   forcing runs with unreasonable dGMST values are excluded from the
%   Pliocene priors. Runs time-slice assmilations 
%   for the various experiments and exports reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme cesm-only_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           cesm-only_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "cesm-cloud";

% Get CESM runs
piRuns = parameters.preindustrialRuns.cesm;
% Remove COSMOS
%badRuns = parameters.excludeRuns;
%remove = ismember(piRuns, badRuns, 'rows');
%piRuns(remove,:) = [];

%piRuns = piRuns([1;3;4],:); %only cesm1
plioRuns = parameters.plioceneRuns.cloud;

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

% Run DA
runDALoc(tag, piRuns, plioRuns, 6000);

end