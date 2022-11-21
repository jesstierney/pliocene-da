function[runs] = Burls2014
%% parameters.plioceneRuns.Burls2014 Returns the metadata for all Pliocene-like runs from Burls and Fedorov (2014)
% ----------
%   [runs] = parameters.plioceneRuns.Burls2014
%   Returns the metadata for all Pliocene-like climate model runs from Burls
%   and Fedorov (2014). The output has one row per run and 2 columns. The first
%   column lists the climate model associated with each run, and the second
%   column lists the experimental ID.
% ----------
%   Outputs:
%       runs (string matrix [nRuns x 2]): The name of the climate model
%           (column 1) and the experiment ID (column 2) for each run

%%%%%%%
model = "CESM1.0.4";
experiments = [
    "20p-ILWP-1590deg-tropx2-T31-gx3v7"
    "20p-ILWP-1590deg-tropx4-T31-gx3v7"
    "20p-ILWP-3060deg-tropx8-T31-gx3v7"
    "20p-LWP-1590deg-T31-gx3v7"
    "20p-op-LWP-1590deg-T31-gx3v7"
    "40p-ILWP-1590deg-tropx2-0.9x1.25-gx1v6"
    "40p-ILWP-1590deg-tropx2-T31-gx3v7"
    "40p-ILWP-1590deg-tropx4-T31-gx3v7"
    "40p-ILWP-3060deg-tropx8-T31-gx3v7"
    "40p-LWP-1590deg-0.9x1.25-gx1v6"
    "40p-LWP-1590deg-T31-gx3v7"
    "40p-op-LWP-1590deg-T31-gx3v7"
    "60p-ILWP-1590deg-tropx2-0.9x1.25-gx1v6"
    "60p-ILWP-1590deg-tropx2-T31-gx3v7"
    "60p-ILWP-1590deg-tropx4-T31-gx3v7"
    "60p-ILWP-3060deg-tropx8-T31-gx3v7"
    "60p-LWP-1590deg-0.9x1.25-gx1v6"
    "60p-LWP-1590deg-T31-gx3v7"
    "60p-op-LWP-1590deg-T31-gx3v7"
    "80p-ILWP-1590deg-tropx2-T31-gx3v7"
    "80p-ILWP-1590deg-tropx4-T31-gx3v7"
    "80p-ILWP-3060deg-tropx8-T31-gx3v7"
    "80p-LWP-1590deg-T31-gx3v7"
    "80p-op-LWP-1590deg-T31-gx3v7"
    ];
%%%%%%%%%%

% Append the model name to each experiment
model = repmat(model, numel(experiments), 1);
runs = [model, experiments];

end