%% runAnalysis  - Implements the analysis used to assimilate the Pliocene reconstruction

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
% PSMs. The inputs are the names given to each PSM within DASH.
PSM.download('bayspar');
PSM.download('bayspline');
PSM.download('baymag');

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
estimateProxies('preindustrial', 0, 'preindustrial', 'lat', 'lon');
estimateProxies('mid-pliocene', 3.25, 'pliocene', 'pLat325', 'pLon325');
estimateProxies('early-pliocene', 4.75, 'pliocene', 'pLat475', 'pLon475');

%% Compute proxy error-variances
%
% This function calculates conservative global, and Osman-scaled R error variances
% for the proxies. It creates two NetCDFs named "R-conservative.nc" and
% "R-osman.nc". The R variances are built using the values in "parameters.globalR",
%  and "parameters.osmanScaling". 
calculateR;

%% Run the assimilations
%
% These functions run an assimilation for a time step and save the updated
% ensemble mean in a MAT-file. The inputs are:
%   1. A label for the assimilation. The name of the MAT-file will match
%      this label
%   2. The age of the assimilated time step (in Ma). This should match one
%      of the ages in the time metadata of "proxies.grid"
%   3. The label/file name of the proxy estimates to use for this assimilation
%   4. Used to select the R-variances to use. Should either be 'conservative' or 'osman'
%   5. (optional) Used to select the climate model runs that should be
%      used as ensemble members. If not specified, uses all runs in the ensemble
%   6. (optional) Used to select the proxy sites that should be used in the
%      DA. If not specified, uses all available proxy records.

% An example using CESM-only and UK-only
piCESM = parameters.preindustrialRuns.cesm;
plioCESM = parameters.plioceneRuns.cesm;
ukSites = gridfile('proxies').metadata.site(:,2) == "uk";

% Get the labels for the saved files
tag = 'UK-only_CESM-only';
timeSliceNames = ["preindustrial","mid-pliocene","early-pliocene"];
labels = strcat(timeSliceNames, "_", tag, "_R-conservative");

% Run the assimilation for each time slice
assimilate(labels(1), 0, 'preindustrial', 'conservative', piCESM, ukSites);
assimilate(labels(2), 3.25, 'mid-pliocene', 'conservative', plioCESM, ukSites);
assimilate(labels(3), 4.75, 'early-pliocene', 'conservative', plioCESM, ukSites);


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