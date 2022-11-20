function[] = COSMOS_eoi400
%% COSMOS_eoi400  Pre-processes the data for the COSMOS eoi400 run
% ----------
%   COSMOS_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "COSMOS_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "COSMOS_eoi400.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","sos","sic"];
istripolar = [false, false, false, false, false];
lonNames = ["lon","lon","lon","lon","lon"];
latNames = ["lat","lat","lat","lat","lat"];
conversions = [NaN, 273.15, NaN, NaN, NaN];
conversionTypes = ["", "+", "", "", ""];

% Get the files / file patterns. 
files = [...
    "Eoi400.TotalPrecip_CMIP6_name_pr_2650-2749_monthly_mean_time_series.nc";
    "Eoi400.NearSurfaceAirTemp_CMIP6_name_tas_2650-2749_monthly_mean_time_series.nc";
    "Eoi400.SeaSurfaceTemp_CMIP6_name_tos_2650-2749_monthly_mean_time_series.nc";
    "Eoi400.SeaSurfaceSalinity_CMIP6_name_sos_2650-2749_monthly_mean_time_series.nc";
    "Eoi400.SeaIceAreaFraction_CMIP6_name_sic_2650-2749_monthly_mean_time_series.nc";
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