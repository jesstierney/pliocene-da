function[] = GISS_ModelE2_e280
%% GISS_ModelE2_e280  Pre-processes the data for the GISS-ModelE2 E280 run
% ----------
%   GISS_ModelE2_e280
%   Loads variables from the raw output data files, computes climatologies,
%   and regrids variables to 1x1 resolution. Exports pre-processed
%   variables to NetCDF.
% ----------
%   Outputs:
%       Creates a NetCDF file named "GISS-ModelE2_e280.nc" in the current
%       directory.

% Get the file patterns
prPattern =   "pr_Amon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
tasPattern =  "tas_Amon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
tosPattern =     "tos_Omon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
sosPattern =     "sos_Omon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";
siconcPattern =  "siconca_SImon_GISS-E2-1-G_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc";

% Preallocate 
pr = NaN(144, 90, 1212);
tas = NaN(144, 90, 1212);
tos = NaN(144, 90, 1212);
sos = NaN(144, 90, 1212);
siconc = NaN(144, 90, 1212);

% Iterate through file sets
startYears = [4150, 4201];
stopYears = [4200, 4250];
times = {1:612, 613:1212};
for k = 1:2

    % Get file names
    prFile = sprintf(prPattern, startYears(k), stopYears(k));
    tasFile = sprintf(tasPattern, startYears(k), stopYears(k));
    tosFile = sprintf(tosPattern, startYears(k), stopYears(k));
    sosFile = sprintf(sosPattern, startYears(k), stopYears(k));
    siconcFile = sprintf(siconcPattern, startYears(k), stopYears(k));

    % Load variables
    pr(:,:,times{k}) = ncread(prFile, 'pr');
    tas(:,:,times{k}) = ncread(tasFile, 'tas');
    tos(:,:,times{k}) = ncread(tosFile, 'tos');
    sos(:,:,times{k}) = ncread(sosFile, 'sos');
    siconc(:,:,times{k}) = ncread(siconcFile, 'siconca');
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

lon = ncread(tosFile, 'lon');
lat = ncread(tosFile, 'lat');
tos = regrid.curvilinear(lon, lat, tos);

% SOS
[nLon, nLat] = size(sos, 1:2);
sos = reshape(sos, nLon, nLat, 12, []);
sos = mean(sos, 4);

lon = ncread(sosFile, 'lon');
lat = ncread(sosFile, 'lat');
sos = regrid.curvilinear(lon, lat, sos);

% SICONC
[nLon, nLat] = size(siconc, 1:2);
siconc = reshape(siconc, nLon, nLat, 12, []);
siconc = mean(siconc, 4);

lon = ncread(siconcFile, 'lon');
lat = ncread(siconcFile, 'lat');
siconc = regrid.curvilinear(lon, lat, siconc);

% Export to NetCDF
file = "GISS-ModelE2_e280.nc";
exportNetCDF(file, pr, tas, tos, sos, siconc);

end