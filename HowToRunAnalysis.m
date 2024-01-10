%% Instructions to implement the analysis used to create the Pliocene reconstruction

%% Build the gridfiles
%
% These functions build the gridfile catalogues for the climate model
% output and the proxy records. 
% % These functions will create a gridfile for the proxies "proxies.grid",
% and a gridfile for each climate model output variable: "pr.grid",
% "tas.grid", "tos.grid", "sos.grid", and "siconc.grid"
% 
% The inputs to these scripts are the folders
% that contain the NetCDF files holding the required data. The folder file
% paths should be expressed *relative* to the current directory. If you are
% running these lines from the same folder as "runAnalysis.m", then these
% paths should be correct. If you run these lines from within the
% "gridfiles" folder, then you should add "../" to the beginning of each
% folder path.
modelFolder = 'input_data/model_output/preprocessed'; 
proxyFolder = 'input_data/proxy_records';            
buildModelGridfiles(modelFolder);
buildProxyGridfile(proxyFolder);

%% Build the state vector ensembles
%
% These functions build the state vector ensembles for the preindustrial
% and pliocene runs. Each function will create a ".ens" file holding the
% associated ensemble. The first input is a label for the ensemble - this
% label will be the name of the file. The second input is a list of
% experimental tags (i.e. model runs) that should be included in the
% ensemble.
%
% You can edit the model runs included in an ensemble by editing
% "parameters.preindustrialRuns" and "parameters.plioceneRuns"
% respectively. A list of model run tags can be found in
% "data/model_output/Contents.md"
piRuns = parameters.preindustrialRuns.all;
plioRuns = parameters.plioceneRuns.all;
buildEnsemble('preindustrial', piRuns);
buildEnsemble('pliocene', plioRuns);

%% Download the PSMs
%
% These functions use the PSM interface in DASH to download the necessary
% PSMs. The inputs are the names given to each PSM within DASH. useLatest
% will download the latest versions of the PSMs.
PSM.download('bayspar', 'latest', true);
PSM.download('bayspline', 'latest', true);
PSM.download('baymag', 'latest', true);

%% Generate the proxy estimates
%
% These functions generate the proxy estimates. Each creates a NetCDF file
% holding the proxy estimates for a particular assimilation time period.
% The inputs are:
%   1. A label for the estimates. The name of the NetCDF file will match this label
%   2. The age of the time slice (in Ma). 
%   3. The name of the ensemble file to use for generating estimates
%   4. The name of the column of "site" metadata holding latitude
%      coordinates. (IDs of site metadata columns can be found in the metadata
%      of "proxies.grid")
%   5. The name of the column holding longitude coordinates
%   6. (optional) Used to indicate whether Mediterranean UK records should
%      use annual or seasonal values. If unset, uses seasonal.
% run estimateProxies in the estimates folder to ensure files are saved
% there.

% Standard seasonal windows based on modern seasonality
estimateProxies('preindustrial_uk-med-seasonal_mgcaH', 0, 'preindustrial', 'lat', 'lon');
estimateProxies('mid-pliocene_uk-med-seasonal_mgcaH', 3.25, 'pliocene', 'pLat325', 'pLon325');
estimateProxies('early-pliocene_uk-med-seasonal_mgcaH', 4.75, 'pliocene', 'pLat475', 'pLon475');

% Annual UK in the Mediterranean
%estimateProxies('preindustrial_uk-med-annual', 0, 'preindustrial', 'lat', 'lon', true);
%estimateProxies('mid-pliocene_uk-med-annual', 3.25, 'pliocene', 'pLat325', 'pLon325', true);
%estimateProxies('early-pliocene_uk-med-annual', 4.75, 'pliocene', 'pLat475', 'pLon475', true);

% Annual UK everywhere
estimateProxies('preindustrial_uk-all-annual_mgcaH', 0, 'preindustrial', 'lat', 'lon', false, true); 
estimateProxies('mid-pliocene_uk-all-annual_mgcaH', 3.25, 'pliocene', 'pLat325', 'pLon325', false, true);
estimateProxies('early-pliocene_uk-all-annual_mgcaH', 4.75, 'pliocene', 'pLat475', 'pLon475', false, true);

%Dynamic Mg/Ca seasonality (changes w/ prior)
estimateProxies('preindustrial_uk-med_seasonal_mgDynamic_mgcaH', 0, 'preindustrial', 'lat', 'lon', false, false ,true); 
estimateProxies('mid-pliocene_uk-all-annual_mgDynamic_mgcaH', 3.25, 'pliocene', 'pLat325', 'pLon325', false, true, true);
estimateProxies('early-pliocene_uk-all-annual_mgDynamic_mgcaH', 4.75, 'pliocene', 'pLat475', 'pLon475', false, true, true);
%% Compute proxy error-variances
%
% This function calculates conservative global, and Osman-scaled R error variances
% for the proxies. It creates two NetCDFs named "R-conservative.nc" and
% "R-plio.nc". The R variances are built using the values in "parameters.globalR",
%  and "parameters.plioScaling". 
% run this function in the R-error-variances folder to ensure files are
% saved there.
calculateR;

%% Run the assimilations
%
% These functions run an assimilation for a time step and save the updated
% ensemble mean in a MAT-file. The inputs to the "assimilate" function are:
%   1. A label for the assimilation. The name of the MAT-file will match
%      this label
%   2. The label/file name of the proxy estimates to use for this assimilation
%   3. Used to select the R-variances to use. Should either be 'conservative' or 'osman'
%   4. (optional) Used to select the climate model runs that should be
%      used as ensemble members. If not specified, uses all runs in the ensemble
%   5. (optional) Used to select the proxy sites that should be used in the
%      DA. If not specified, uses all available proxy records.

% %%% An example using CESM-only and UK-only
% 
% % Select the climate model runs and proxy sites
% piCESM = parameters.preindustrialRuns.cesm;
% plioCESM = parameters.plioceneRuns.cesm;
% ukSites = gridfile('proxies').metadata.site(:,2) == "uk";
% 
% % Get the labels for the saved files
% tag = 'UK-only_CESM-only';
% timeSliceNames = ["preindustrial","mid-pliocene","early-pliocene"];
% labels = strcat(timeSliceNames, "_", tag, "_R-conservative");
% 
% % Run the assimilation for each time slice
% assimilate(labels(1), 'preindustrial', 'conservative', piCESM, ukSites);
% assimilate(labels(2), 'mid-pliocene', 'conservative', plioCESM, ukSites);
% assimilate(labels(3), 'early-pliocene', 'conservative', plioCESM, ukSites);


%% Export the assimilations to NetCDF
% 
% This combines the assimilations for the three time slices and exports
% them to a NetCDF file. The inputs are:
%   1. A label for the exported reconstruction. The name of the NetCDF file
%      will match this label
%   2. The label of the preindustrial assimilation
%   3. The label of the mid-Pliocene assimilation
%   4. The label of the early-Pliocene assimilation

newFile = strcat(tag, "_R-conservative");
exportReconstruction(newFile, labels(1), labels(2), labels(3));

%% Reconstruct with different experimental configurations
%
% The following functions run assimilations and export reconstructions
% for several different experimental configuration. Each function runs
% reconstructions using a different set of priors. These are:
%   pliomip:   PlioMIP2 runs + Ran Feng's runs, excluding COSMOS
%   pliomipCloud:       All runs, excluding COSMOS and unrealistic cloud runs
%   cesm-only:  All CESM runs, excluding unrealistic cloud runs
% The functions can be use to test combination of:
%   A. All proxy sites / UK sites only, and
%   B. Annual / Seasonal Mediterranean UK sites

%example: this will run the tests for the PlioMIP group:
pliomip;


%% Test assimilation parameters
%
% This performs validation testing of the localization radius and R scaling
% parameters for the assimilation. Given a set of localization radii and R
% scaling values, the function will run a parameter sweep, testing each
% possible combination of radius and scaling values.
%
% The parameter sweep uses a series of single-proxy knockout experiments to
% validate each parameter combination. For a given parameter combination,
% the function removes one proxy record from the network and then
% assimilates the PSM inputs for that knockout-record using the remaining
% proxies in the network. It then reruns the PSM on the updated inputs and
% compares the output proxy value to the real knockout proxy record. This
% process iterates over every proxy in the network. The differences between
% the validation proxy values and the real proxy values estimate the error
% associated with a given parameter combination.
%
% The inputs to the "testParameters" function are:
%   1. A label for the output file
%   2. The R scaling values to test
%   3. The localization radii to test
%   4. The label of the Ye values to use for assimilation
%   5. The label of the initial R values to scale
%   6. (Optional) The climate model runs to include in the ensemble
%
% You can see examples of how to run the "testParameters" function in the
% "standardTests" and "beokTests" functions, which are located in the
% "parameter-validation" folder.

% example:
pliomipTests;
