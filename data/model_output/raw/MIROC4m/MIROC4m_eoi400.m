function[] = MIROC4m_eoi400
%% MIROC4m_eoi400  Pre-processes the data for the MIROC4m EOI400 run
% ----------
%   MIROC4m_eoi400
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "MIROC4m_eoi400.nc" in the current
%       directory.

% Get the files
prFile =      "MIROC4m_Eoi400_Amon_pr.nc";
tasFile =     "MIROC4m_Eoi400_Amon_tas.nc";
tosFile =     "MIROC4m_Eoi400_Omon_tos.nc";
sosFile =     "MIROC4m_Eoi400_Omon_so.nc";
siconcFile =  "MIROC4m_Eoi400_Omon_siconc.nc";

% Load variables
pr = ncread(prFile, 'pr');
tas = ncread(tasFile, 'tas');
tos = ncread(tosFile, 'tos');
sos = ncread(sosFile, 'so');
siconc = ncread(siconcFile, 'siconc');

% Extract depths
sos = sos(:,:,1,:);

% PR
[nLon, nLat] = size(pr, 1:2);
pr = reshape(pr, nLon, nLat, 12, []);
pr = mean(pr, 4);

lon = ncread(prFile, 'lon');
lat = ncread(prFile, 'lat');
pr = regrid.curvilinear(lon, lat, pr);

% TAS
[nLon, nLat] = size(tas, 1:2);
tas = reshape(tas, nLon, nLat, 12, []);
tas = mean(tas, 4);

lon = ncread(tasFile, 'lon');
lat = ncread(tasFile, 'lat');
tas = regrid.curvilinear(lon, lat, tas);

tas = tas + 273.15;  % Convert to K

% TOS
[nLon, nLat] = size(tos, 1:2);
tos = reshape(tos, nLon, nLat, 12, []);
tos = mean(tos, 4);

lon = ncread(tosFile, 'lon');
lat = ncread(tosFile, 'lat');
[tos, lon] = regrid.lon360(lon, tos);
tos = regrid.curvilinear(lon, lat, tos);

% SOS
[nLon, nLat] = size(sos, 1:2);
sos = reshape(sos, nLon, nLat, 12, []);
sos = mean(sos, 4);

lon = ncread(sosFile, 'lon');
lat = ncread(sosFile, 'lat');
[sos, lon] = regrid.lon360(lon, sos);
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
[nLon, nLat] = size(siconc, 1:2);
siconc = reshape(siconc, nLon, nLat, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'lon');
lat = ncread(siconcFile, 'lat');
[siconc, lon] = regrid.lon360(lon, siconc);
siconc = regrid.curvilinear(lon, lat, siconc);

% Export to NetCDF
file = "MIROC4m_eoi400.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end