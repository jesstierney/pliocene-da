function[] = CESM1_2_2_burls_erfani(run)

% Get exported NetCDF file
run = string(run);
exportFile = strcat('CESM1.2.2_', replace(run,'_','-'), ".nc");

% Note characteristics of raw output
names = ["PRECC","PRECL","TREFHT","TEMP","SALT","ICEFRAC"];
istripolar = [false, false, true, true, false];
lonNames = ["lon","lon","TLONG","TLONG","lon"];
latNames = ["lat","lat","TLAT","TLAT","lat"];
conversions = [1000*60*60*24, NaN, NaN, NaN, 100];
conversionTypes = ["*", "", "", "", "*"];

% Get the years associated with the run
if endsWith(run, "gx1v6")
    years = [151, 200];
else
    years = [701, 800];
end

% Get the file patterns
camFile = sprintf("%s.cam2.h0.%%02.f.mavg_%04.f-%04.f.nc", run, years(1), years(2));
tempFile = sprintf("%s.pop.h.TEMP.mavg_%04.f-%04.f.nc", run, years(1), years(2));
saltFile = sprintf("%s.pop.h.SALT.mavg_%04.f-%04.f.nc", run, years(1), years(2));
files = [camFile, camFile, camFile, tempFile, saltFile, camFile];

% Construct pr from precc and precl
[precc, files(1)] = load.climatologyRange(files(1), names(1));
[precl, files(2)] = load.climatologyRange(files(2), names(2));
pr = precc + precl;
files(1) = [];
names(1) = [];

% Load the other variables
[tas, files(2)] = load.climatologyRange(files(2), names(2));
tos = load.climatology(files(3), names(3), 1);
sos = load.climatology(files(4), names(4), 1);
[siconc, files(5)] = load.climatologyRange(files(5), names(5));

% Process the variables and export to NetCDF
variables = {pr, tas, tos, sos, siconc};
variables = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes);
[pr, tas, tos, sos, siconc] = variables{:};
exportNetCDF(exportFile, pr, tas, tos, sos, siconc);

end