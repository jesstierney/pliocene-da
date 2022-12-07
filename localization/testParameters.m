function[] = testParameters(label, Rscaling, locRadii, estimatesLabel, Rlabel, runs)
%% testParameters  Performs single-proxy knockout validation experiments for R scaling weights and localization radii
% ----------
%   testParameters(label, Rscaling, locRadii, estimatesLabel, Rlabel, runs)
%   Conducts single-proxy knockout assimilations for a set of localization
%   radii and R scaling weights. Iterates over R scaling weights and localization
%   radii to test each parameter combination. Within each parameter combination,
%   iterates over each proxy site in the network, and performs a single-proxy
%   knockout validation test. In each test, a single proxy record is excluded
%   from the network and an assimilation is run using the remaining
%   network and the current localization radius/R scaling weight. The 
%   assimilation updates the PSM inputs for the knockout proxy,
%   and the updated inputs are used to estimate the knockout proxy record
%   from the posterior. These posterior estimates can be used as validation
%   metrics. Note that these tests are performed for a single assimilation
%   time step, so the validation outputs have size (nSite x nRScaling x nLocRadii).
%
%   Saves results to a NetCDF file whose name follows the pattern <label>_parameter-tests.nc. 
%   The NetCDF includes (1) the validation values for each proxy record,
%   and (2) the difference between the validation values and the real proxy
%   records (Validation - Real).
%
%   testParameters(..., runs)
%   Runs the tests using specific climate model runs as ensemble
%   members.
% ----------
%   Inputs:
%       label (string scalar): A label for the localization tests. The name
%           of the output NetCDF file will follow the pattern <label>_parameter-tests.nc
%       Rscaling (numeric vector): The R scaling weights to test. These
%           weights are applied to the original R values indicated by the
%           Rlabel input.
%       locRadii (numeric vector): The localizaion radii to test. Units
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
%
%   Outputs:
%       Creates a NetCDF file whose name follows the pattern <label>_parameter-tests.nc

%% Initial setup

% Defaults for optional inputs
if ~exist('runs','var')
    runs = [];
end

% Load observations, estimates, uncertainties, members, sites
[Y, Ye, Rinitial, members, YeFile] = loadCoreInputs(estimatesLabel, Rlabel, runs, []);

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
nScaling = numel(Rscaling);
nLocs = numel(locRadii);
Ypost = NaN(nSite, nScaling, nLocs);

% Seed the random number generator so results are repoducible (BayWatch
% PSMs use random draws)
rng('default');

% Create a progress bar. Set it to delete when this function exits
message = sprintf('Testing parameters: %s', label);
h = waitbar(0, message);
deleteBar = onCleanup( @()delete(h) );
progress = 0;
nTests = numel(Ypost);


%% Knockout assimilations

% Compute localization weights for each radius
for k = 1:nLocs
    [wloc, yloc] = dash.localize.gc2d(siteCoords, siteCoords, locRadii(k));

    % Compute scaled R values
    for r = 1:nScaling
        R = Rinitial * Rscaling(r);

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
            progress = progress + 1;
            waitbar(progress/nTests, h);
        end
    end
end

% Compute validation deltas
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
nccreate(file, 'scalings', 'Dimensions', {'scalings',nScaling}, 'Datatype', 'double');
nccreate(file, 'radii', 'Dimensions', {'radii',nLocs}, 'Datatype', 'double');
nccreate(file, 'Ypost',  'Dimensions', {'sites',nSite,'scalings',nScaling,'radii',nLocs}, 'Datatype', 'double');
nccreate(file, 'deltaY', 'Dimensions', {'sites',nSite,'scalings',nScaling,'radii',nLocs}, 'Datatype', 'double');
nccreate(file, 'estimates_label', 'Datatype', 'string');
nccreate(file, 'R_label', 'Datatype', 'string');

% Attributes
ncwriteatt(file, 'sites_columns', 'Description', 'The type of metadata stored along each column of site');
ncwriteatt(file, 'sites', 'Description', 'The proxy sites (and associated metadata)');
ncwriteatt(file, 'scalings', 'Description', 'The R scaling weights tested in the experiment');
ncwriteatt(file, 'scalings', 'Details', 'Tested R values are computed by applying the R scaling weights to the original R values');
ncwriteatt(file, 'radii', 'Description', 'The localization radii tested in the experiment');
ncwriteatt(file, 'radii', 'Units', 'kilometers');
ncwriteatt(file, 'Ypost', 'Description', 'The validation proxy values.');
ncwriteatt(file, 'Ypost', 'Details', 'Values are calculated by running the PSM for the knockout proxy on the posterior mean');
ncwriteatt(file, 'deltaY', 'Description', 'The difference between the validation values and the real proxy values');
ncwriteatt(file, 'deltaY', 'Details', 'Y_validation - Y_observed');
ncwriteatt(file, 'estimates_label', 'Description', 'The label of the proxy estimates used for the tests');
ncwriteatt(file, 'R_label', 'Description', 'The label of the original R values used for the tests');

% Write
ncwrite(file, 'sites_columns', columns');
ncwrite(file, 'sites', proxies);
ncwrite(file, 'scalings', Rscaling);
ncwrite(file, 'radii', locRadii);
ncwrite(file, 'Ypost', Ypost);
ncwrite(file, 'deltaY', deltaY)
ncwrite(file, 'estimates_label', estimatesLabel);
ncwrite(file, 'R_label', Rlabel);

end