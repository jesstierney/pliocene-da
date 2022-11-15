function[] = buildModelGridfiles(folder)

% Get the NetCDF files in the folder
contents = dir(folder);
files = string({contents.name})';
netcdf = endsWith(files, ".nc");
files = files(netcdf);
filepaths = fullfile(folder, files);

% Create metadata object
[lon, lat] = regrid.points;
lat = lat';
time = (1:12)';
run = split(files, '_');
run(:,2) = erase(run(:,2), ".nc");
metadata = gridMetadata('lon',lon,'lat',lat,'time',time,'run',run);

% Preallocate variable units and descriptions
variables = ["pr","tas","tos","sos","siconc"];
nVars = numel(variables);
units = strings(nVars, 1);
descriptions = strings(nVars, 1);

% Read units and descriptions from first NetCDF file
file = filepaths(1);
for v = 1:nVars
    units(v) = ncreadatt(file, variables(v), 'Units');
    descriptions(v) = ncreadatt(file, variables(v), 'Description');
end

% Create a gridfile for each variable
nVars = numel(variables);
grids = cell(nVars, 1);
for v = 1:nVars
    grids{v} = gridfile.new(variables(v), metadata, 'overwrite');
    grids{v}.addAttributes('Description', descriptions(v), 'Units', units(v));
end

% Add each NetCDF data source
order = ["lon","lat","time"];
for f = 1:numel(files)
    sourceMetadata = metadata.index('run', f);
    for v = 1:nVars
        grids{v}.add("netcdf", filepaths(f), variables(v), order, sourceMetadata);
    end
end

end