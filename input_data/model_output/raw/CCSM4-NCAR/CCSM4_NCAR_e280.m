function[] = CCSM4_NCAR_e280
%% CCSM4_NCAR_e280  Pre-processes the data for the CCSM4-NCAR E280 run
% ----------
%   CCSM4_NCAR_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CCSM4-NCAR_e280.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CCSM4-NCAR_e280.nc";

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "b40.B1850.f09_g16.preind.cam.h0.PRECC.0081.0180.nc";
    "b40.B1850.f09_g16.preind.cam.h0.PRECL.0081.0180.nc";
    "b40.B1850.f09_g16.preind.cam.h0.TREFHT.0081.0180.nc";
    "b.e12.B1850C5CN.f09_g16.preind.ccsm4.pop.h.TEMP.%04.f01-%04.f12.nc";
    "b.e12.B1850C5CN.f09_g16.preind.ccsm4.pop.h.SALT.%04.f01-%04.f12.nc";
    "b40.B1850.f09_g16.preind.cam.h0.ICEFRAC.0081.0180.nc";
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
startYears = [51, 101, 151];
stopYears = [100, 150, 180];
[tos, files(3)] = load.fileYears(files(3), names(3), startYears, stopYears, 1, true);
[sos, files(4)] = load.fileYears(files(4), names(4), startYears, stopYears, 1, true);

% Remove extra leading years from ocean variables
tos = tos(:,:,361:end);
sos = sos(:,:,361:end);

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end