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
cloudRuns = [parameters.plioceneRuns.Erfani2019;
             parameters.plioceneRuns.Burls2014];
piBackground = ["CESM1.2.2", "cheyctrl"];
season = parameters.dGMST.season;
deltas = dGMST(piBackground, cloudRuns, season);

% Remove runs outside of acceptable limits
limits = parameters.dGMST.limits;
badDeltas = deltas<limits(1) | deltas>limits(2);
badRuns = cloudRuns(badDeltas, :);
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Run DA
runDALoc(tag, piRuns, plioRuns, 12000);

end