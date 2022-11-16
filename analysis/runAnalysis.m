
%% Build the gridfiles
%
% These functions build the gridfile catalogues for the climate model
% output and the proxy records. The inputs to these scripts are the folders
% that contain the NetCDF files holding the required data. The folder file
% paths should be expressed *relative* to the "runAnalysis.m" file.
%
% These functions will create a gridfile for the proxies "proxies.grid",
% and a gridfile for each climate model output variable: "pr.grid",
% "tas.grid", "tos.grid", "sos.grid", and "siconc.grid"
modelFolder = '../../data/model_output/preprocessed'; 
proxyFolder = '../../data/proxy_records';            
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
piRuns = parameters.preindustrialRuns;
plioRuns = parameters.plioceneRuns;
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
assimilate('preindustrial-Rc', 0, 'preindustrial', 'conservative');
assimilate('mid-pliocene-Rc', 3.25, 'mid-pliocene', 'conservative');
assimilate('early-pliocene-Rc', 4.75, 'early-pliocene', 'conservative');

%% Export the assimilations to NetCDF
% 
% This combines the assimilations for the three time slices and exports
% them to a NetCDF file. The inputs are:
%   1. A label for the exported reconstruction. The name of the NetCDF file
%      will match this label
%   2. The label of the preindustrial assimilation
%   3. The label of the mid-Pliocene assimilation
%   4. The label of the early-Pliocene assimilation
exportReconstruction('prelim-recon', 'preindustrial-Rc', 'mid-pliocene-Rc', 'early-pliocene-Rc');

