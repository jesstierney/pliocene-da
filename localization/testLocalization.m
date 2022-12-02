function[] = testLocalization(label, radii, estimatesLabel, Rlabel, runs)
%% testLocalization  Runs single-proxy knockout validation experiments for a set of localization radii
% ----------
%   testLocalization(label, radii, estimatesLabel, Rlabel)
%   Conducts single-proxy knockout assimilations for a set of localization
%   radii. Iterates over localization radii and proxy sites. In each
%   iteration, a single proxy record is excluded from the network and an
%   assimilation is run using the remaining network and a given localization
%   radius. The assimilation updates the PSM inputs for the knockout proxy,
%   and the updated inputs are used to estimate the knockout proxy record
%   from the posterior. These posterior estimates can be used as validation
%   metrics. Note that these tests are performed for a single assimilation
%   time step, so the validation outputs have size (nSite x nLocs).
%
%   Saves results to a NetCDF file whose name follows the pattern <label>_loctests.nc. 
%   The NetCDF includes (1) the validation values for each proxy record,
%   and (2) the difference between the validation values and the real proxy
%   records (Validation - Real).
%
%   testLocalization(..., runs)
%   Runs the assimilation using specific climate model runs as ensemble
%   members.
% ----------
%   Inputs:
%       label (string scalar): A label for the localization tests. The name
%           of the output NetCDF file will follow the pattern <label>_loctests.nc
%       radii (numeric vector): A set of localization radii to test. Units
%           should be in kilometers
%       estimatesLabel (string scalar): The label of the proxy estimates to
%           use for the localization tests. This is the first part of the
%           name of a proxy estimates NetCDF file (the part of the file name
%           before "_estimates.nc")
%       Rlabel (string scalar): Indicates the type of R values to use.
%           Either "conservative" or "osman"
%       runs (string matrix [nRuns x 2]): Indicates the climate model runs
%           that should be used as ensemble members in the assimilation.
%           These values should be from the "run" metadata of the ensemble.
%           The first column is the climate model associated with each run,
%           and the second column is the experimental tag. If not
%           specified, uses all available runs.

%% Initial setup

% Defaults for optional inputs
if ~exist('runs','var')
    runs = [];
end

% Load observations, estimates, uncertainties, members, sites
[Y, Ye, R, members, YeFile] = loadCoreInputs(estimatesLabel, Rlabel, runs, []);

% Get the PSM and coordinates for each site
latName = ncread(YeFile, 'latColumn');
lonName = ncread(YeFile, 'lonColumn');
age = ncread(YeFile, 'time');
[models, siteCoords] = buildPSMs(age, latName, lonName);

% Load the seasonal TOS and SOS values for each site
tos = ncread(YeFile, 'tos_seasonal');
sos = ncread(YeFile, 'sos_seasonal');

% Limit the ensemble to the indicated members
Ye = Ye(:, members);   
tos = tos(:, members);
sos = sos(:, members);

% Preallocate the validation estimates
nSite = numel(models);
nLocs = numel(radii);
Ypost = NaN(nSite, nLocs);


%% Knockout assimilations

% Create a progress bar. Set it to delete when this function exits
h = waitbar(0, 'Testing localization');
deleteBar = onCleanup( @()delete(h) );

% Compute localization weights for each radius
for k = 1:nLocs
    [wloc, yloc] = dash.localize.gc2d(siteCoords, siteCoords, radii(k));

    % Do a series of single-proxy knockouts. Determine whether each knockout is
    % a Mg/Ca proxy
    for s = 1:nSite
        sites = [1:s-1, s+1:nSite];
        mg = isa(models{s}, 'PSM.baymag');

        % Build the prior from the PSM inputs. Get localization weights
        X = [tos(s,:); sos(s,:)];
        w = repmat(wloc(s,sites), 2, 1);
        y = yloc(sites, sites);

        % Run the knockout assimilation
        kf = kalmanFilter;
        kf = kf.prior(X);
        kf = kf.observations(Y(sites));
        kf = kf.estimates(Ye(sites,:));
        kf = kf.uncertainties(R(sites));
        kf = kf.localize(w, y);
        output = kf.run;

        % Run PSM on posterior
        A = output.Amean;
        if ~mg
            A = A(1,:);
        end
        Ypost(s,k) = models{s}.estimate(A);

        % Update progress bar
        progress = ((k-1)*nSite + s) / (nSite*nLocs);
        waitbar(progress, h);
    end
end

% Also compute delta
deltaY = Ypost - Y;

%% Export to NetCDF

% Load proxy metadata
proxies = gridfile('proxies').metadata;
columns = proxies.attributes.site_metadata_columns;
proxies = proxies.site;

% Get sizes
[nSite, nLocs] = size(Ypost);
nSiteCols = numel(columns);

% Create variables
file = strcat(label, "_estimates.nc");
nccreate(file, 'sites_columns', 'Dimensions', {'sites_columns', nSiteCols}, 'Format', 'netcdf4', 'Datatype', 'string');
nccreate(file, 'sites', 'Dimensions', {'sites',nSite,'sites_columns',nSiteCols}, 'Datatype', 'string');
nccreate(file, 'radii', 'Dimensions', {'radii',nLocs}, 'Datatype', 'double');
nccreate(file, 'Ypost', 'Dimensions', {'sites',nSite,'radii',nLocs}, 'Datatype', 'double');
nccreate(file, 'deltaY', 'Dimensions', {'sites',nSite,'radii',nLocs}, 'Datatype', 'double');

% Attributes
ncwriteatt(file, 'sites_columns', 'Description', 'The type of metadata stored along each column of site');
ncwriteatt(file, 'sites', 'Description', 'The proxy sites (and associated metadata)');
ncwriteatt(file, 'radii', 'Description', 'The localization radii tested in the experiment');
ncwriteatt(file, 'radii', 'Units', 'kilometers');
ncwriteatt(file, 'Ypost', 'Description', 'The validation proxy values.');
ncwriteatt(file, 'Ypost', 'Details', 'Values are calculated by running the PSM for the knockout proxy on the posterior mean');
ncwriteatt(file, 'deltaY', 'Description', 'The difference between the validation values and the real proxy values');
ncwriteatt(file, 'deltaY', 'Details', 'Y_validation - Y_observed');

% Write
ncwrite(file, 'sites_columns', columns');
ncwrite(file, 'sites', proxies);
ncwrite(file, 'radii', radii);
ncwrite(file, 'Ypost', Ypost);
ncwrite(file, 'deltaY', deltaY)

end