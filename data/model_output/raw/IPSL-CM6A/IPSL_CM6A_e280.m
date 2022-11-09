function[] = IPSL_CM6A_e280
%% IPSL_CM6A_e280  Pre-processes the data for the IPSL-CM6A E280 run
% ----------
%   IPSL_CM6A_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "IPSL-CM6A_e280.nc" in the current
%       directory.

% Get the files
prFile =      "pr_Amon_IPSL-CM6A-LR_piControl_r1i1p1f1_gr_185001-234912.nc";
tasFile =     "tas_Amon_IPSL-CM6A-LR_piControl_r1i1p1f1_gr_185001-234912.nc";
tosFile =     "tos_Omon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";
sosFile =     "sos_Omon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";
siconcFile =  "siconc_SImon_IPSL-CM6A-LR_piControl_r1i1p1f1_gn_185001-234912.nc";

% Load variables
start = [1 1 1];
count = [Inf, Inf, 1200];
pr = ncread(prFile, 'pr', start, count);
tas = ncread(tasFile, 'tas', start, count);
tos = ncread(tosFile, 'tos', start, count);
sos = ncread(sosFile, 'sos', start, count);
siconc = ncread(siconcFile, 'siconc', start, count);

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
pr = regrid.curvilinear(lon, lat, pr);

pr = pr * (60*60*24); % Convert to mm/day

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

lon = ncread(tosFile, 'nav_lon');
lat = ncread(tosFile, 'nav_lat');
lon = regrid.lon360(lon);
tos = regrid.tripolar(lon, lat, tos);

% SOS
[nLon, nLat] = size(sos, 1:2);
sos = reshape(sos, nLon, nLat, 12, []);
sos = mean(sos, 4);

lon = ncread(sosFile, 'nav_lon');
lat = ncread(sosFile, 'nav_lat');
lon = regrid.lon360(lon);
sos = regrid.tripolar(lon, lat, sos);

% SICONC
[nLon, nLat] = size(siconc, 1:2);
siconc = reshape(siconc, nLon, nLat, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'nav_lon');
lat = ncread(siconcFile, 'nav_lat');
lon = regrid.lon360(lon);
siconc = regrid.tripolar(lon, lat, siconc);

% Export to NetCDF
file = "IPSL-CM6A_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end