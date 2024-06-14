%% Instructions to implement the analysis used to create the Pliocene reconstruction

%% Step 1: Build the gridfiles
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
% running these lines from the same folder as "HowToRunAnalysis.m", then these
% paths should be correct. If you run these lines from within the
% "gridfiles" folder, then you should add "../" to the beginning of each
% folder path.
%
% Note that the NetCDF model data files are not in the Github repository
% because they are too large. So, you need to download them from the Zenodo
% repository here: https://zenodo.org/doi/10.5281/zenodo.11646735
% You can put these model files in the preprocessed folder:
modelFolder = 'input_data/model_output/preprocessed'; 
% The proxy record files are small so are in the Github repository.
proxyFolder = 'input_data/proxy_records';            
buildModelGridfiles(modelFolder);
buildProxyGridfile(proxyFolder);

%% Step 2: Build the state vector ensembles
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

%% Step 3: Download the PSMs
%
% These functions use the PSM interface in DASH to download the necessary
% PSMs. The inputs are the names given to each PSM within DASH. useLatest
% will download the latest versions of the PSMs.
PSM.download('bayspar', 'latest', true);
PSM.download('bayspline', 'latest', true);
PSM.download('baymag', 'latest', true);

%% Step 4: Generate the proxy estimates
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

% Annual UK everywhere
estimateProxies('preindustrial_uk-all-annual_mgcaH', 0, 'preindustrial', 'lat', 'lon', false, true); 
estimateProxies('mid-pliocene_uk-all-annual_mgcaH', 3.25, 'pliocene', 'pLat325', 'pLon325', false, true);
estimateProxies('early-pliocene_uk-all-annual_mgcaH', 4.75, 'pliocene', 'pLat475', 'pLon475', false, true);

%Dynamic Mg/Ca seasonality (changes w/ prior)
estimateProxies('preindustrial_uk-med_seasonal_mgDynamic_mgcaH', 0, 'preindustrial', 'lat', 'lon', false, false ,true); 
estimateProxies('mid-pliocene_uk-all-annual_mgDynamic_mgcaH', 3.25, 'pliocene', 'pLat325', 'pLon325', false, true, true);
estimateProxies('early-pliocene_uk-all-annual_mgDynamic_mgcaH', 4.75, 'pliocene', 'pLat475', 'pLon475', false, true, true);
%% Step 5: Compute proxy error-variances
%
% This function calculates conservative global, R error variances
% for the proxies. It creates a NetCDF named "R-conservative.nc"
% The R variances are built using the values in "parameters.globalR".
% There is an existing file in the repository that matches the uploaded
% proxy data. If you add proxy data you would need to re-create this file.
% run this function in the R-error-variances folder to ensure files are
% saved there.
calculateR;

%% Step 6: Run assimilations
%
% To repeat the experiments in the paper, go into the da-experiments
% folder, where you will find pliomip.m, pliomipCloud.m, and cesmCloud.m,
% scripts that set up the assimilate call to run PlioMIP2-only, full prior,
% and Cloud-only experiments.
%
% You can also design your own experiment by calling assimilate or
% assimilate or assimilateWithLoc (the function to do a DA with
% localization) directly, but it is easier to modify the set-ups in the
% da-experiments folder
%
% The inputs to the assimilate/assimilateWithLoc functions are:
%   1. A label for the assimilation. The name of the MAT-file will match
%      this label
%   2. The label/file name of the proxy estimates to use for this assimilation
%   3. Used to select the R-variances to use. Should be 'conservative'
%   4. assimilateWithLoc Only: the localization radius
%   5. (optional) Used to select the climate model runs that should be
%      used as ensemble members. If not specified, uses all runs in the ensemble
%   6. (optional) Used to select the proxy sites that should be used in the
%      DA. If not specified, uses all available proxy records.

%% Step 7: Export the assimilations to NetCDF
% 
% This combines the assimilations for the three time slices and exports
% them to a NetCDF file. This is already called by the pliomip.m, 
% pliomipCloud.m, and cesmCloud.m scripts so you don't need to run it
% separately.
%
% The inputs are:
%   1. A label for the exported reconstruction. The name of the NetCDF file
%      will match this label
%   2. The label of the preindustrial assimilation
%   3. The label of the mid-Pliocene assimilation
%   4. The label of the early-Pliocene assimilation
%
% here is a simple example:
% newFile = "myDAoutput";
% exportReconstruction(newFile, labels(1), labels(2), labels(3));

%% Extra: test assimilation parameters
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
% "parameter-validation" folder.

% example:
% pliomipTests;
