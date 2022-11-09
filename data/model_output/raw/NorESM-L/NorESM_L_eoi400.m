function[] = NorESM_L_eoi400
%% NorESM_L_eoi400  Pre-processes the data for the NorESM-L eoi400 run
% ----------
%   NorESM_L_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "NorESM-L_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "NorESM-L_eoi400.nc";

% Note characteristics of raw output
names = ["PRECT","TREFHT","sst","sss","aice"];
istripolar = [false, false, false, false, true];
lonNames = ["lon","lon","lon","lon","TLON"];
latNames = ["lat","lat","lat","lat","TLAT"];
conversions = [1000*60*60*24, NaN, NaN, NaN, NaN];
conversionTypes = ["*", "", "", "", ""];

% Get the files / file patterns. Note whether variables are stored in
% multiple files
files = [...
    "NorESM-L_Eoi400_PRECT.nc";
    "NorESM-L_Eoi400_TREFHT.nc";
    "NorESM-L_Eoi400.sst.climo.nc";
    "NorESM-L_Eoi400.sss.climo.nc";
    "NorESM-L_Eoi400_aice.nc";
    ];

% Load the variables
pr = load.monthly(files(1), names(1));
tas = load.monthly(files(2), names(2));
tos = load.climatology(files(3), names(3));
sos = load.climatology(files(4), names(4));
siconc = load.monthly(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end