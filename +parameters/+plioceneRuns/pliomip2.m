function[runs] = pliomip2
%% parameters.plioceneRuns.pliomip2  Returns the metadata for all Pliocene (EOI400) runs from PlioMIP2
% ----------
%   [runs] = parameters.plioceneRuns.pliomip2
%   Returns the metadata for all Pliocene model runs from PlioMIP2. This is
%   the collection of EOI400 experiments. The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

%%%%%%%%%
experiment = "eoi400";
models = [...
    "CCSM4-NCAR"
    "CCSM4-UoT"
    "CESM1.2"
    "CESM2"
    "COSMOS"
    "EC-Earth3.3"
    "GISS-ModelE2"
    "HadCM3"
    "HadGM3"
    "IPSL-CM5A"
    "IPSL-CM5A2"
    "IPSL-CM6A"
    "MIROC4m"
    "NorESM-L"
    "NorESM1-F"
    ];
%%%%%%%%%%

% Combine the models and experiments into an array
experiments = repmat(experiment, [numel(models),1]);
runs = [models, experiments];

end