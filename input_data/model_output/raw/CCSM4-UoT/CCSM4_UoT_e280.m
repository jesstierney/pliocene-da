function[] = CCSM4_UoT_e280
%% CCSM4_UoT_e280  Pre-processes the data for the CCSM4-UoT E280 run
% ----------
%   CCSM4_UoT_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CCSM4-UoT_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CCSM4-UoT_e280.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","sos","siconc"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","lon","lon","lon"];
latNames = ["lat","lat","lat","lat","lat"];
conversions = [60*60*24, NaN, NaN, NaN, NaN];
conversionTypes = ["*", "", "", "", ""];

% Get the files / file patterns. 
files = [...
    "pr_Amon_UofT-CCSM4_piControl_r1i1p1f1_gn_150101-160012.nc";
    "tas_Amon_UofT-CCSM4_piControl_r1i1p1f1_gn_150101-160012.nc";
    "tos_Omon_UofT-CCSM4_piControl_r1i1p1f1_gn_150101-160012.nc";
    "sos_Omon_UofT-CCSM4_piControl_r1i1p1f1_gn_150101-160012.nc";
    "siconc_SImon_E280_UofT-CCSM4_gr.nc";
    ];

% Load the variables
pr = load.monthly(files(1), names(1));
tas = load.monthly(files(2), names(2));
tos = load.monthly(files(3), names(3));
sos = load.monthly(files(4), names(4));
siconc = load.monthly(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end