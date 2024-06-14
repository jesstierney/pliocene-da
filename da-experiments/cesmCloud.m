function[] = cesmCloud
%% cesmCloud  Runs the DA using CESM cloud runs, excluding runs with unrealistic dGMST
% ----------
%   Runs the DA using cloud priors only. Cloud
%   forcing runs with unreasonable dGMST values (outside [1 8]) are excluded
% ----------
%   Outputs:
%       Assimilated time slices: .mat files with the naming
%           scheme cesm-cloud_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates NetCDF files with the naming scheme
%           cesm-cloud_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "cesm-cloud";

% Get all CESM runs for PI slice
piRuns = parameters.preindustrialRuns.cesm;

% Get cloud runs for Pliocene slices
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

% Run the DA with 24000 km localization
runDALoc(tag, piRuns, plioRuns, 24000);

% if you want to run the DA w/o localization you would need this command:
% runDAnoLoc(tag, piRuns, plioRuns);

% if you want to save deviations, use this, but note that this ONLY outputs
% .mat files and not NetCDF:
% runDALocDev(tag, piRuns, plioRuns, 24000);

end