function[] = HadCM3_eoi400
%% HadCM3_eoi400  Pre-processes the data for the HadCM3 eoi400 run
% ----------
%   HadCM3_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "HadCM3_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "HadCM3_eoi400.nc";

% Note characteristics of raw output
names = ["precip","temp","temp_opf","salinity_opf","iceconc_opf"];
istripolar = [false, false, false, false, false];
lonNames = ["longitude","longitude","lon2","lon2","lon2"];
latNames = ["latitude","latitude","lat1","lat1","lat1"];
conversions = [NaN, NaN, NaN, NaN, 100];
conversionTypes = ["", "", "", "", "*"];

% Get the files / file patterns. 
files = [...
    "eoi400.TotalPrecipitation.%03.f.nc";
    "eoi400.NearSurfaceTemperature.%03.f.nc";
    "EOI400_2400_2499_Monthly_SST.nc";
    "EOI400_2400_2499_Monthly_SSS.nc";
    "EOI400_2400_2499_Monthly_iceconc.nc";
    ];

% Load the variables
[pr, files(1)] = load.fileRange(files(1), names(1), [0 99], 1);
[tas, files(2)] = load.fileRange(files(2), names(2), [0 99], 1);
tos = load.climatology(files(3), names(3));
sos = load.climatology(files(4), names(4));
siconc = load.climatology(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end