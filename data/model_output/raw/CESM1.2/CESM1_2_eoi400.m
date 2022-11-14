function[] = CESM1_2_eoi400
%% CESM1_2_eoi400  Pre-processes the data for the CESM1.2 eoi400 run
% ----------
%   CESM1_2_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CESM1.2_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CESM1.2_eoi400.nc";

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "b.e12.B1850.f09_g16.PMIP4-pliomip2.cam.h0.PRECC.1101.1200.nc";
    "b.e12.B1850.f09_g16.PMIP4-pliomip2.cam.h0.PRECL.1101.1200.nc";
    "b.e12.B1850.f09_g16.PMIP4-pliomip2.cam.h0.TREFHT.1101.1200.nc";
    "b.e12.B1850.f09_g16.PIMP4-pliomip2.modMed.pop.h.TEMP.%04.f01-%04.f12.nc";
    "b.e12.B1850.f09_g16.PIMP4-pliomip2.modMed.pop.h.SALT.%04.f01-%04.f12.nc";
    "b.e12.B1850.f09_g16.PMIP4-pliomip2.cam.h0.ICEFRAC.1101.1200.nc";
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
startYears = [1100, 1150];
stopYears = [1149, 1199];
[tos, files(3)] = load.fileYears(files(3), names(3), startYears, stopYears, 1);
[sos, files(4)] = load.fileYears(files(4), names(4), startYears, stopYears, 1);

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end