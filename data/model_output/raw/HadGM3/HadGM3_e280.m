function[] = HadGM3_e280
%% HadGM3_e280  Pre-processes the data for the HadGM3 E280 run
% ----------
%   HadGM3_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "HadGM3_e280.nc" in the current
%       directory.

% Get the files
prFile =      "clims_hadgem3_pi_precip_final.nc";
tasFile =     "clims_hadgem3_pi_airtemp_final.nc";
tosFile =     "clims_hadgem3_pi_sst.nc";
sosFile =     "clims_hadgem3_pi_sal.nc";
siconcFile =  "clims_hadgem3_pi_fraccice_final.nc";

% Load variables
pr = ncread(prFile, 'precip');
tas = ncread(tasFile, 'temp');
tos = ncread(tosFile, 'tos');
sos = ncread(sosFile, 'sal');
siconc = ncread(siconcFile, 'seaice');

% PR
lon = ncread(prFile, 'longitude');
lat = ncread(prFile, 'latitude');
pr = regrid.curvilinear(lon, lat, pr);

pr = pr * (60*60*24); % Convert to mm/day

% TAS
lon = ncread(tasFile, 'longitude');
lat = ncread(tasFile, 'latitude');
tas = regrid.curvilinear(lon, lat, tas);

% TOS
lon = ncread(tosFile, 'longitude');
lat = ncread(tosFile, 'latitude');
[tos, lon] = regrid.lon360(lon, tos);
tos = regrid.curvilinear(lon, lat, tos);

% SOS
sos = squeeze(sos(:,:,1,:));
lon = ncread(sosFile, 'longitude');
lat = ncread(sosFile, 'latitude');
[sos, lon] = regrid.lon360(lon, sos);
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
lon = ncread(siconcFile, 'longitude');
lat = ncread(siconcFile, 'latitude');
siconc = regrid.curvilinear(lon, lat, siconc);

siconc = siconc * 100;  % Convert to percentage

% Export to NetCDF
file = "HadGM3_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end