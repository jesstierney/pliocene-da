
% Build the gridfiles
modelFolder = '../../data/model_output/preprocessed';   % Relative to the "runAnalysis" file
proxyFolder = '../../data/proxy_records';               % Relative to the "runAnalysis" file
buildModelGridfiles(modelFolder);
buildProxyGridfile(proxyFolder);

% Build the state vector ensembles
piRuns = parameters.preindustrialRuns;
plioRuns = parameters.plioceneRuns;
buildEnsemble('preindustrial', piRuns);
buildEnsemble('pliocene', plioRuns);

% Download the PSMs
PSM.download('bayspar');
PSM.download('bayspline');
PSM.download('baymag');

% Generate the proxy estimates
estimateProxies('preindustrial', 0, 'preindustrial', 'lat', 'lon');
estimateProxies('early-pliocene', 3.25, 'pliocene', 'pLat325', 'pLon325');
estimateProxies('late-pliocene', 4.75, 'pliocene', 'pLat475', 'pLon475');

% Compute proxy error-variances
calculateR;

% Run the assimilation

