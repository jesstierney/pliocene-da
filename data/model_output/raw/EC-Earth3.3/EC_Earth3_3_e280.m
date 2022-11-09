function[] = EC_Earth3_3_e280
%% EC_Earth3_3_e280  Pre-processes the data for the EC_Earth3_3 E280 run
% ----------
%   EC_Earth3_3_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "EC-Earth3.3_e280.nc" in the current
%       directory.

% Get the file patterns
prPattern =   "pr_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc";
tasPattern =  "tas_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc";
tosPattern =     "tos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
sosPattern =     "sos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
siconcPattern =  "siconc_SImon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";

% Preallocate 
pr = NaN(320, 160, 1200);
tas = NaN(320, 160, 1200);
tos = NaN(362, 292, 1200);
sos = NaN(362, 292, 1200);
siconc = NaN(362, 292, 1200);

% Iterate through file sets
startYear = 2219;
stopYear = 2318;
for year = startYear:stopYear
    time = (year-startYear)*12 + (1:12);

    % Get file names
    prFile = sprintf(prPattern, year, year);
    tasFile = sprintf(tasPattern, year, year);
    tosFile = sprintf(tosPattern, year, year);
    sosFile = sprintf(sosPattern, year, year);
    siconcFile = sprintf(siconcPattern, year, year);

    % Load variables
    pr(:,:,time) = ncread(prFile, 'pr');
    tas(:,:,time) = ncread(tasFile, 'tas');
    tos(:,:,time) = ncread(tosFile, 'tos');
    sos(:,:,time) = ncread(sosFile, 'sos');
    siconc(:,:,time) = ncread(siconcFile, 'siconc');
end

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
pr = regrid.curvilinear(lon, lat, pr);

pr = pr * (60*60*24);  % Convert to mm/day

% TAS
[nLon, nLat] = size(tas, 1:2);
tas = reshape(tas, nLon, nLat, 12, []);
tas = mean(tas, 4);

lon = ncread(tasFile, 'lon');
lat = ncread(tasFile, 'lat');
tas = regrid.curvilinear(lon, lat, tas);

% TOS
[nLon, nLat] = size(tos, 1:2);
tos = reshape(tos, nLon, nLat, 12, []);
tos = mean(tos, 4);

lon = ncread(tosFile, 'longitude');
lat = ncread(tosFile, 'latitude');
tos = regrid.tripolar(lon, lat, tos);

% SOS
[nLon, nLat] = size(sos, 1:2);
sos = reshape(sos, nLon, nLat, 12, []);
sos = mean(sos, 4);

lon = ncread(sosFile, 'longitude');
lat = ncread(sosFile, 'latitude');
sos = regrid.tripolar(lon, lat, sos);

% SICONC
[nLon, nLat] = size(siconc, 1:2);
siconc = reshape(siconc, nLon, nLat, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'longitude');
lat = ncread(siconcFile, 'latitude');
siconc = regrid.tripolar(lon, lat, siconc);

% Export to NetCDF
file = "EC-Earth3.3_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end