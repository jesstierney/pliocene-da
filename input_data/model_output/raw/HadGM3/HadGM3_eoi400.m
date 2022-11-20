function[] = HadGM3_eoi400
%% HadGM3_eoi400  Pre-processes the data for the HadGM3 eoi400 run
% ----------
%   HadGM3_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "HadGM3_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "HadGM3_eoi400.nc";

% Note characteristics of raw output
names = ["precip","temp","tos","sal","seaice"];
istripolar = [false, false, false, false, false];
lonNames = ["longitude","longitude","longitude","longitude","longitude"];
latNames = ["latitude","latitude","latitude","latitude","latitude"];
conversions = [60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "clims_hadgem3_pliocene_precip_final.nc";
    "clims_hadgem3_pliocene_airtemp_final.nc";
    "clims_hadgem3_pliocene_sst_final.nc";
    "clims_hadgem3_pliocene_sal_final.nc";
    "clims_hadgem3_pliocene_fraccice_final.nc";
    ];

% Load the variables
pr = load.climatology(files(1), names(1));
tas = load.climatology(files(2), names(2));
tos = load.climatology(files(3), names(3));
sos = load.climatology(files(4), names(4), 1);
siconc = load.climatology(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end