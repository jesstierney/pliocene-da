function[] = runAnalysis

% Move to the location of this file, but return to original location when
% the function is exited
here = mfilename('fullpath');
home = pwd;
goback = onCleanup( @()cd(home) );
cd(here);

% Build the gridfiles
modelFolder = '../data/model_output/preprocessed';   % Relative to the "runAnalysis" file
proxyFolder = '../data/proxy_records';               % Relative to the "runAnalysis" file
buildModelGridfiles(modelFolder);
buildProxyGridfile(proxyFolder);

% Build the state vector ensembles
piRuns = ["e280", "preind", "cheyctrl"];
plioRuns = ["eoi400","eo400new","pi400","plio","pliob17", "cheyco2", ...
                          "n05","n10","n15","n20","p05","p10","p15","p20"];
buildEnsemble('preindustrial', piRuns);
buildEnsemble('pliocene', plioRuns);

