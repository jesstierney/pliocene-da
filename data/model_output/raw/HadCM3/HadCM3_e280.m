function[] = HadCM3_e280
%% HadCM3_e280  Pre-processes the data for the HadCM3 E280 run
% ----------
%   HadCM3_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "HadCM3_e280.nc" in the current
%       directory.

% Get the files / file patterns
prPattern =   "e280.TotalPrecipitation.%03.f.nc";
tasPattern =  "e280.NearSurfaceTemperature.%03.f.nc";
tosFile =     "E280_2900_2999_Monthly_SST.nc";
sosFile =     "E280_2900_2999_Monthly_SSS.nc";
siconcFile =  "E280_2900_2999_Monthly_iceconc.nc";

% Preallocate 
pr = NaN(96, 73, 1200);
tas = NaN(96, 73, 1200);

% Load variables that span multiple files
for k = 0:99
    prFile = sprintf(prPattern, k);
    tasFile = sprintf(tasPattern, k);

    time = k*12+(1:12);
    pr(:,:,time) = ncread(prFile, 'precip');
    tas(:,:,time) = ncread(tasFile, 'temp');
end

% Load single file variables
tos = ncread(tosFile, 'temp_opf');
sos = ncread(sosFile, 'salinity_opf');
siconc = ncread(siconcFile, 'iceconc_opf');

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'longitude');
lat = ncread(prFile, 'latitude');
pr = regrid.curvilinear(lon, lat, pr);

% TAS
[nLon, nLat] = size(tas, 1:2);
tas = reshape(tas, nLon, nLat, 12, []);
tas = mean(tas, 4);

lon = ncread(tasFile, 'longitude');
lat = ncread(tasFile, 'latitude');
tas = regrid.curvilinear(lon, lat, tas);

% TOS
lon = ncread(tosFile, 'lon2');
lat = ncread(tosFile, 'lat1');
tos = regrid.curvilinear(lon, lat, tos);

% SOS
lon = ncread(sosFile, 'lon2');
lat = ncread(sosFile, 'lat1');
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
lon = ncread(siconcFile, 'lon2');
lat = ncread(siconcFile, 'lat1');
siconc = regrid.curvilinear(lon, lat, siconc);

siconc = siconc * 100;  % Convert to percentage

% Export to NetCDF
file = "HadCM3_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end