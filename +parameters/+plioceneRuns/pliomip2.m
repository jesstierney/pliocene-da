function[runs] = pliomip2
%% parameters.plioceneRuns.pliomip2  Returns the metadata for all PlioMIP2 EOI400 runs
% ----------
%   [runs] = parameters.plioceneRuns.pliomip2
%   Returns the names of all EOI400 (pliocene-like) climate model runs from 
%   PlioMI2. The output has one row per run and 2 columns. The first column
%   lists the climate model associated with each run, and the second column
%   lists the experimental ID (in this case "eoi400").
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each PlioMIP2
%           EOI400 run.

%%%%%%%%%
experiment = "eoi400";
models = [...
    "CCSM4-NCAR"
    "CCSM4-UoT"
    "CESM1.0.5"
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