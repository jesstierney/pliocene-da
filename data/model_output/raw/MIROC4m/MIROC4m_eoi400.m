function[] = MIROC4m_eoi400
%% MIROC4m_eoi400  Pre-processes the data for the MIROC4m eoi400 run
% ----------
%   MIROC4m_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "MIROC4m_eoi400.nc" in the current
%       directory.

% Set exported NetCDF file
exportFile = "MIROC4m_eoi400.nc";

% Note characteristics of raw output
names = ["pr","tas","tos","so","siconc"];
istripolar = [false, false, false, false, false];
lonNames = ["lon","lon","lon","lon","lon"];
latNames = ["lat","lat","lat","lat","lat"];
conversions = [NaN, 273.15, NaN, NaN, NaN];
conversionTypes = ["", "+", "", "", ""];

% Get the files / file patterns. Note whether variables are stored in
% multiple files
files = [...
    "MIROC4m_Eoi400_Amon_pr.nc";
    "MIROC4m_Eoi400_Amon_tas.nc";
    "MIROC4m_Eoi400_Omon_tos.nc";
    "MIROC4m_Eoi400_Omon_so.nc";
    "MIROC4m_Eoi400_Omon_siconc.nc";
    ];

% Load the variables
pr = load.monthly(files(1), names(1));
tas = load.monthly(files(2), names(2));
tos = load.monthly(files(3), names(3));
sos = load.climatology(files(4), names(4), 1);
siconc = load.monthly(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end