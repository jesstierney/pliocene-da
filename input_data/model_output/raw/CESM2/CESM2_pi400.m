function[] = CESM2_pi400
%% CESM2_pi400  Pre-processes the data for the CESM2 pi400 run
% ----------
%   CESM2_pi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CESM2_pi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CESM2_pi400.nc";

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, 1000, 100];
conversionTypes = ["*", "", "", "*", "*"];

% Get the files / file patterns. 
files = [...
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.PRECC.0801.0900.nc";
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.PRECL.0801.0900.nc";
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.TREFHT.0801.0900.nc";
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.TEMP.0801.0900.0.nc";
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.SALT.0801.0900.0.nc";
    "b.e21.B1850.f09_g17.CMIP6-piControl.400.cam.h0.ICEFRAC.0801.0900.nc";
    ];

% Compute pr as the sum of PRECC and PRECL
precc = load.monthly(files(1), names(1));
precl = load.monthly(files(2), names(2));
pr = precc + precl;
files(1) = [];
names(1) = [];

% Load the other variables
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