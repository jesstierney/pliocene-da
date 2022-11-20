function[] = CESM1_2_2_preind
%% CESM1_2_2_preind  Pre-processes the data for the CESM1.2.2 preind run
% ----------
%   CESM1_2_2_preind
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "CESM1.2.2_preind.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "CESM1.2.2_preind.nc";

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "PreInd_ciso_T31_gx3v7.cam.h0.2901-3000._%02.f_climo.nc";
    "PreInd_ciso_T31_gx3v7.cam.h0.2901-3000._%02.f_climo.nc";
    "PreInd_ciso_T31_gx3v7.cam.h0.2901-3000._%02.f_climo.nc";
    "PreInd_ciso_T31_gx3v7.pop.h.2901-3000._%02.f_climo.nc";
    "PreInd_ciso_T31_gx3v7.pop.h.2901-3000._%02.f_climo.nc";
    "PreInd_ciso_T31_gx3v7.cam.h0.2901-3000._%02.f_climo.nc";
    ];

% Construct pr from precc and precl
[precc, files(1)] = load.climatologyRange(files(1), names(1));
[precl, files(2)] = load.climatologyRange(files(2), names(2));
pr = precc + precl;
files(1) = [];
names(1) = [];

% Load the other variables
[tas, files(2)] = load.climatologyRange(files(2), names(2));
[tos, files(3)] = load.climatologyRange(files(3), names(3), 1);
[sos, files(4)] = load.climatologyRange(files(4), names(4), 1);
[siconc, files(5)] = load.climatologyRange(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end