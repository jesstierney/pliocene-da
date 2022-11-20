function[] = IPSL_CM6A_e280
%% IPSL_CM6A_e280  Pre-processes the data for the IPSL-CM6A E280 run
% ----------
%   IPSL_CM6A_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "IPSL-CM6A_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "IPSL-CM6A_e280.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","sos","siconc"];
istripolar = [false, false, true, true, true];
lonNames = ["lon","lon","nav_lon","nav_lon","nav_lon"];
latNames = ["lat","lat","nav_lat","nav_lat","nav_lat"];
conversions = [60*60*24, NaN, NaN, NaN, NaN];
conversionTypes = ["*", "", "", "", ""];

% Get the files / file patterns. Note whether variables are stored in
% multiple files
files = [...
    "pr_Amon_IPSL-CM6A-LR_piControl_r1i1p1f1_gr_185001-234912.nc";
    "tas_Amon_IPSL-CM6A-LR_piControl_r1i1p1f1_gr_185001-234912.nc";
    "tos_Omon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";
    "sos_Omon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";
    "siconc_SImon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";
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