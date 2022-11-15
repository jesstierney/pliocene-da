function[] = buildProxyGridfile(folder)

% Get the proxy NetCDF
file = fullfile(folder, 'proxies.nc');

% Read metadata from file
IDs = ncread(file, 'site');
lats = ncread(file, 'lat');
lons = ncread(file, 'lon');
pLat325 = ncread(file, 'pLat325');
pLon325 = ncread(file, 'pLon325');
pLat475 = ncread(file, 'pLat475');
pLon475 = ncread(file, 'pLon475');
cleaning = ncread(file, 'cleaning');
type = ncread(file, 'type');
species = ncread(file, 'species');

time = ncread(file, 'time');
timeBounds = ncread(file, 'timeBounds');

% Build metadata object
coords = string([lats, lons, pLat325, pLon325, pLat475, pLon475]);
site = [IDs, coords, cleaning, type, species];
site(ismissing(site)) = "";
metadata = gridMetadata('site', site, 'time', time);
metadata = metadata.addAttributes(...
    'site_metadata_columns', ["ID", "lat","lon","pLat325","pLon325","pLat475","pLon475","cleaning","type","species"],...
    'timeBounds', timeBounds);

% Create gridfile. Add source file
proxies = gridfile.new('proxies', metadata, 'overwrite');
proxies.add('netcdf', file, 'data', ["site","time"], metadata);

end