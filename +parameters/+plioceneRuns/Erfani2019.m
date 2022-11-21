function[runs] = Erfani2019
%% parameters.plioceneRuns.Erfani2019 Returns the metadata for all Pliocene-like runs from Erfani and Burls (2019)
% ----------
%   [runs] = parameters.plioceneRuns.Erfani2019
%   Returns the metadata for all Pliocene-like climate model runs from
%   Erfani and Burls (2019). The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

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