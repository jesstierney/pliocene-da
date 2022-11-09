function[] = EC_Earth3_3_e280
%% EC_Earth3_3_e280  Pre-processes the data for the EC_Earth3_3 E280 run
% ----------
%   EC_Earth3_3_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "EC-Earth3.3_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "EC-Earth3.3_e280.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","sos","siconc"];
istripolar = [false, false, true, true, true];
lonNames = ["lon","lon","longitude","longitude","longitude"];
latNames = ["lat","lat","latitude","latitude","latitude"];
conversions = [60*60*24, NaN, NaN, NaN, NaN];
conversionTypes = ["*", "", "", "", ""];

% Get the files / file patterns. 
files = [...
    "pr_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc";
    "tas_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc";
    "tos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "sos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "siconc_SImon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    ];

% Load the variables
years = 2219:2318;
[pr, files(1)] = load.fileYears(files(1), names(1), years, years);
[tas, files(2)] = load.fileYears(files(2), names(2), years, years);
[tos, files(3)] = load.fileYears(files(3), names(3), years, years);
[sos, files(4)] = load.fileYears(files(4), names(4), years, years);
[siconc, files(5)] = load.fileYears(files(5), names(5), years, years);

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end