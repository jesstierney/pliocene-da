function[] = cesmOnly
%% cesmOnly  Runs proxy network experiments using CESM runs, excluding cloud runs with unrealistic dGMST
% ----------
%   Runs the current proxy network experiments (detailed in
%   "runNetworkExperiments.m") for priors selected from CESM runs. Cloud
%   forcing runs with unreasonable dGMST values are excluded from the
%   Pliocene priors. Runs time-slice assmilations 
%   for the various experiments and exports reconstructions to NetCDF.
% ----------
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme cesm-only_<prior>_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           cesm-only_<proxy network>_<uk seasonality>.nc    

% Tag for the prior
tag = "cesm-only";

%%%%%%%% Parameters for dGMST calculations
season = 1:12;      % Change this to calculate dGMST over a different season
limits = [0 8];     % Change this to use different dGMST limits
%%%%%%%%%

% Get CESM runs
piCESM = parameters.preindustrialRuns.cesm;
plioCESM = parameters.plioceneRuns.cesm;

% Calculate dGMST values for runs with altered cloud physics
cloudRuns = [parameters.plioceneRuns.Erfani2019;
             parameters.plioceneRuns.Burls2014];
piBackground = ["CESM1.2.2", "cheyctrl"];
deltas = dGMST(piBackground, cloudRuns, season);

% Remove runs outside of acceptable limits
badDeltas = deltas<limits(1) | deltas>limits(2);
badRuns = cloudRuns(badDeltas, :);
remove = ismember(plioCESM, badRuns, 'rows');
plioCESM(remove,:) = [];

% Build reconstructions for different proxy network settings
runNetworkExperiments(tag, piCESM, plioCESM);

end