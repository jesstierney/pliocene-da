function[] = CESM1_2_2_laystrat(tag)
%% CESM1_2_2_laystrat  Pre-processes the data for the CESM1.2.2 lay_strat runs
% ----------
%   CESM1_2_2_laystrat(tag)
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Inputs:
%       tag (string scalar): Indicates the cloud settings used in the run.
%           Options are p05, p10, p15, p20, n05, n10, n15, n20. Here, the n
%           indicates a negative value, and p indicates a positive value.
%
%   Outputs:
%       Creates a NetCDF file named "CESM1.2.2_<tag>.nc" in the current
%       directory.

% Check tag
validTags = ["p05","p10","p15","p20","n05","n10","n15","n20"];
assert(ismember(tag, validTags), 'invalid tag');

% Set exported NetCDF file
exportFile = strcat("CESM1.2.2_", tag, ".nc");

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Parse the file name header
tag = char(tag);
if tag(1) == 'p'
    head = '';
else
    head = 'neg_';
end
if tag(3)=='0'
    value = tag(2);
else
    value = tag(2:3);
end

% Get the file patterns
header = sprintf("%slay_strat_0_%s", head, value);
camFile = strcat(header, "_co2_2_CHEY_PreInd_T31_gx3v7.cam.h0.%02.f.mavg_1701-1800.nc");
popFile = strcat(header, "_co2_2_CHEY_PreInd_T31_gx3v7.pop.h.%02.f.mavg_1701-1800.nc");
files = [camFile; camFile; camFile; popFile; popFile; camFile];

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