function[] = CESM1_2_e280
%% CESM1_2_e280  Pre-processes the data for the CESM1.2 E280 run
% ----------
%   CESM1_2_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CESM1.2_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CESM1.2_e280.nc";

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "b.e12.B1850.f09_g16.preind.cam.h0.PRECC.0701.0800.nc";
    "b.e12.B1850.f09_g16.preind.cam.h0.PRECL.0701.0800.nc";
    "b.e12.B1850.f09_g16.preind.cam.h0.TREFHT.0701.0800.nc";
    "b.e12.B1850C5CN.f09_g16.preind.pop.h.TEMP.%04.f01-%04.f12.nc";
    "b.e12.B1850C5CN.f09_g16.preind.pop.h.SALT.%04.f01-%04.f12.nc";
    "b.e12.B1850.f09_g16.preind.cam.h0.ICEFRAC.0701.0800.nc";
    ];

% Compute pr as the sum of PRECC and PRECL
precc = load.monthly(files(1), names(1));
precl = load.monthly(files(2), names(2));
pr = precc + precl;
files(1) = [];
names(1) = [];

% Load atmospheric variables
tas = load.monthly(files(2), names(2));
siconc = load.monthly(files(5), names(5));

% Load ocean variables
startYears = [701, 751];
stopYears = [750, 800];
[tos, files(3)] = load.fileYears(files(3), names(3), startYears, stopYears, 1);
[sos, files(4)] = load.fileYears(files(4), names(4), startYears, stopYears, 1);

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end