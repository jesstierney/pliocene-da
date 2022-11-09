function[] = IPSL_CM5A2_e280
%% IPSL_CM5A2_e280  Pre-processes the data for the IPSL-CM5A2 E280 run
% ----------
%   IPSL_CM5A2_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "IPSL-CM5A2_e280.nc" in the current
%       directory.

% Get the files
prFile =      "PI.TotalPrecip_pr_6110_6209_monthly_TS.nc";
tasFile =     "PI.NearSurfaceTemp_tas_6110_6209_monthly_TS.nc";
tosFile =     "PI.SeasurfaceTemp_sst_6110_6209_monthly_TS.nc";
sosFile =     "piControl_IPSLCM5A2_SSS.nc";
siconcFile =  "PI.Sicfraction_sic_6110_6209_monthly_TS.nc";

% Load variables
pr = ncread(prFile, 'pr');
tas = ncread(tasFile, 'tas');
tos = ncread(tosFile, 'sst');
sos = ncread(sosFile, 'sos');
siconc = ncread(siconcFile, 'sic');

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
[pr, lon] = regrid.lon360(lon, pr);
pr = regrid.curvilinear(lon, lat, pr);

pr = pr * (60*60*24); % Convert to mm/day

% TAS
[nLon, nLat] = size(tas, 1:2);
tas = reshape(tas, nLon, nLat, 12, []);
tas = mean(tas, 4);

lon = ncread(tasFile, 'lon');
lat = ncread(tasFile, 'lat');
[tas, lon] = regrid.lon360(lon, tas);
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
lon = ncread(sosFile, 'lon');
lat = ncread(sosFile, 'lat');
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
[nLon, nLat] = size(siconc, 1:2);
siconc = reshape(siconc, nLon, nLat, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'nav_lon');
lat = ncread(siconcFile, 'nav_lat');
lon = regrid.lon360(lon);
siconc = regrid.tripolar(lon, lat, siconc);

siconc = siconc * 100;  % Convert to percentage

% Export to NetCDF
file = "IPSL-CM5A2_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end