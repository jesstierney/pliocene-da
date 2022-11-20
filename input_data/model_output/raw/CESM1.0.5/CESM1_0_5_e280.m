function[] = CESM1_0_5_e280
%% CESM1_0_5_e280  Pre-processes the data for the CESM1.0.5 E280 run
% ----------
%   CESM1_0_5_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CESM1.0.5_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CESM1.0.5_e280.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","so","siconc"];
istripolar = [false, false, true, true, true];
lonNames = ["lon","lon","TLONG","TLONG","TLONG"];
latNames = ["lat","lat","TLAT","TLAT","TLAT"];
conversions = [NaN, 273.15, NaN, NaN, NaN];
conversionTypes = ["", "+", "", "", ""];

% Get the files / file patterns. 
files = [...
    "pr_Amon_CESM1.0.5_E280_r1i1p1f1_gn_275001-285012.nc";
    "tas_Amon_CESM1.0.5_E280_r1i1p1f1_gn_275001-285012.nc";
    "tos_Omon_CESM1.0.5_E280_r1i1p1f1_gn_275001-285012.nc";
    "so_Omon_CESM1.0.5_E280_r1i1p1f1_gn_2750-2850.nc";
    "siconc_Omon_CESM1.0.5_E280_r1i1p1f1_gn_275001-285012.nc";
    ];

% Load the variables
pr = load.monthly(files(1), names(1));
tas = load.monthly(files(2), names(2));
tos = load.monthly(files(3), names(3), 1);
sos = load.monthly(files(4), names(4), 1);
siconc = load.monthly(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end