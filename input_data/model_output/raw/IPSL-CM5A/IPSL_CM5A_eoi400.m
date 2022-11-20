function[] = IPSL_CM5A_eoi400
%% IPSL_CM5A_eoi400  Pre-processes the data for the IPSL-CM5A eoi400 run
% ----------
%   IPSL_CM5A_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "IPSL-CM5A_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "IPSL-CM5A_eoi400.nc";

% Note characteristics of raw output
names = ["pr","tas","sst","sosaline","sic"];
istripolar = [false, false, true, false, true];
lonNames = ["lon","lon","nav_lon","lon","nav_lon"];
latNames = ["lat","lat","nav_lat","lat","nav_lat"];
conversions = [60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "Eoi400.TotalPrecip_pr_3581_3680_monthly_TS.nc";
    "Eoi400.NearSurfaceTemp_tas_3581_3680_monthly_TS.nc";
    "Eoi400.SeasurfaceTemp_sst_3581_3680_monthly_TS.nc";
    "Eoi400_IPSLCM5A_SSS.nc";
    "Eoi400.Sicfraction_sic_3581_3680_monthly_TS.nc";
    ];

% Load the variables
pr = load.monthly(files(1), names(1));
tas = load.monthly(files(2), names(2));
tos = load.monthly(files(3), names(3));
sos = load.climatology(files(4), names(4));
siconc = load.monthly(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end