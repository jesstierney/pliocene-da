function[] = NorESM_L_eoi400
%% NorESM_L_eoi400  Pre-processes the data for the NorESM-L EOI400 run
% ----------
%   NorESM_L_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "NorESM-L_eoi400.nc" in the current
%       directory.

% Get the files
prFile =      "NorESM-L_Eoi400_PRECT.nc";
tasFile =     "NorESM-L_Eoi400_TREFHT.nc";
tosFile =     "NorESM-L_Eoi400.sst.climo.nc";
sosFile =     "NorESM-L_Eoi400.sss.climo.nc";
siconcFile =  "NorESM-L_Eoi400_aice.nc";

% Load variables
pr = ncread(prFile, 'PRECT');
tas = ncread(tasFile, 'TREFHT');
tos = ncread(tosFile, 'sst');
sos = ncread(sosFile, 'sss');
siconc = ncread(siconcFile, 'aice');

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
pr = regrid.curvilinear(lon, lat, pr);

pr = pr * (1000*60*60*24); % Convert to mm/day

% TAS
[nLon, nLat] = size(tas, 1:2);
tas = reshape(tas, nLon, nLat, 12, []);
tas = mean(tas, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
tas = regrid.curvilinear(lon, lat, tas);

% TOS
lon = ncread(tosFile, 'lon');
lat = ncread(tosFile, 'lat');
[tos, lon] = regrid.lon180to360(lon, tos);
tos = regrid.curvilinear(lon, lat, tos);

% SOS
lon = ncread(sosFile, 'lon');
lat = ncread(sosFile, 'lat');
[sos, lon] = regrid.lon180to360(lon, sos);
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
[nRows, nCols] = size(siconc, 1:2);
siconc = reshape(siconc, nRows, nCols, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'TLON');
lat = ncread(siconcFile, 'TLAT');
[siconc] = regrid.tripolar(lon, lat, siconc);

% Export to NetCDF
file = "NorESM-L_eoi400.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end