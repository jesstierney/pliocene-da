function[] = runNetworkExperimentsLoc(tag, piRuns, plioRuns)
%% runNetworkExperiments  Creates reconstructions using different proxy network settings
% ----------
%   runNetworkExperiments(tag, piRuns, plioRuns)
%   Given a set of preindustrial and pliocene runs, builds reconstructions
%   using different proxy network settings. Currently, runs reconstructions
%   for each combination of:
%       1. Full proxy network / UK site only, and
%       2. Annual / seasonal UK sites in the Mediterranean
%
%   Assimilates the time slices for each proxy-network experiment, and
%   exports the reconstruction to a NetCDF. This creates 4 reconstruction
%   NetCDF files, each labeled with tags for the different proxy-network
%   experiments.
% ----------
%   Inputs:
%       tag (string scalar): A tag used to identify the prior.
%       piRuns (string matrix [nPiRuns x 2]): The climate model runs that
%           should be included in the preindustrial prior.
%       plioRuns (string matrix [nPlioRuns x 2]): The climate model runs
%           that should be included in the Pliocene priors.
%
%   Outputs:
%       Assimilated time slices: Creates 12 .mat files with the naming
%           scheme <time slice>_<prior>_<proxy network>_<uk seasonality>.nc
%       Reconstructions: Creates 4 NetCDF files with the naming scheme
%           <prior>_<proxy network>_<uk seasonality>.nc    

% Parameters / labels for the assimilation
timeSliceTags = ["preindustrial"; "mid-pliocene"; "early-pliocene"];
ukSeasonTags = ["uk-med-annual"];
Rtag = "conservative";

% Either assimilate all proxies or UK-only
proxyTypes = gridfile('proxies').metadata.site(:,2);
ukSites = proxyTypes=="uk";
allSites = true(size(ukSites));

networks = [allSites, ukSites];
networkTags = ["all-proxies"];

% Loop through the different proxy-network settings
for n = 1:numel(networkTags)
    for s = 1:numel(ukSeasonTags)

        % Get labels for the reconstruction, estimates, and assimilated
        % time slices
        reconTags = [tag, networkTags(n), ukSeasonTags(s)];
        reconLabel = join(reconTags, "_");
        estimates = strcat( timeSliceTags, "_", ukSeasonTags(s) );
        labels = strcat( timeSliceTags, "_", reconLabel );

        % Assimilate each time slice
        LocRadius = 30000;
        assimilateWithLoc(labels(1), estimates(1), Rtag, LocRadius, piRuns, networks(:,n));
        assimilateWithLoc(labels(2), estimates(2), Rtag, LocRadius, plioRuns, networks(:,n));
        assimilateWithLoc(labels(3), estimates(3), Rtag, LocRadius, plioRuns, networks(:,n));

        % Export to NetCDF
        exportReconstruction(reconLabel, labels(1), labels(2), labels(3));
    end
end

end