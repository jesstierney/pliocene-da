function[] = GISS_ModelE2_e280
%% GISS_ModelE2_e280  Pre-processes the data for the GISS-ModelE2 E280 run
% ----------
%   GISS_ModelE2_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "GISS-ModelE2_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "GISS-ModelE2_e280.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","sos","siconca"];
istripolar = [false, false, false, false, false];
lonNames = ["lon","lon","lon","lon","lon"];
latNames = ["lat","lat","lat","lat","lat"];
conversions = [60*60*24, NaN, NaN, NaN, NaN];
conversionTypes = ["*", "", "", "", ""];

% Get the files / file patterns. 
files = [...
    "pr_Amon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "tas_Amon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "tos_Omon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "sos_Omon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    "siconca_SImon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
    ];

% Load the variables
startYears = [4150, 4201];
stopYears  =  [4200, 4250];
[pr, files(1)] = load.fileYears(files(1), names(1), startYears, stopYears);
[tas, files(2)] = load.fileYears(files(2), names(2), startYears, stopYears);
[tos, files(3)] = load.fileYears(files(3), names(3), startYears, stopYears);
[sos, files(4)] = load.fileYears(files(4), names(4), startYears, stopYears);
[siconc, files(5)] = load.fileYears(files(5), names(5), startYears, stopYears);

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end