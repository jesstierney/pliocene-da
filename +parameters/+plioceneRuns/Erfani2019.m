function[runs] = Erfani2019
%% parameters.plioceneRuns.Erfani2019  Returns the metadata for all Pliocene-like runs from Erfani and Burls (2019)
% ----------
%   runs = parameters.plioceneRuns.Erfani2019
%
% ----------

%%%%%%%
model = "CESM1.2.2";
experiments = [
    "cheyco2"
    
    "p05"
    "p10"
    "p15"
    "p20"
    
    "n05"
    "n10"
    "n15"
    "n20"
    ];
%%%%%%%

% Append the model name to each experiment
model = repmat(model, numel(experiments), 1);
runs = [model, experiments];

end