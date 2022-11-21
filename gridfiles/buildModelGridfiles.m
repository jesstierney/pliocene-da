function[] = buildModelGridfiles(folder)
%% buildModelGridfiles  Builds gridfiles for the climate model output variables
% ----------
%   buildModelGridfiles(folder)
%   Builds gridfiles for each of the climate model output variables: pr,
%   tas, tos, sos, and siconc. Each gridfile is named <variable name>.grid.
%   For example: "tas.grid". 
%
%   The first input lists a folder that contains NetCDF files holding 
%   the pre-processed climate model output. The function uses each NetCDF
%   file as a data source in each gridfile catalogue. The NetCDF files
%   should follow the naming convention "<model name>_<experiment ID>.nc".
%   Neither the model name, nor the experiment ID should have any
%   underscores. You can generate the pre-processed NetCDF files by running
%   the "processModelOutput.m" function.
%
%   Each gridfile includes metadata for the spatial field, as well as the
%   included climate model runs. The first column of the "run" metadata
%   indicates the climate model used to produce the output (for example, "CESM1.2"), 
%   and the second column indicates an ID for the experiment (for example, 
%   "e280" or "eoi400").
% ----------
%   Inputs:
%       folder (string scalar): The path to the folder holding the
%           pre-processed NetCDF files. The path should be relative to the
%           current directory.
%
%   Outputs:
%       Creates 5 gridfiles: "pr.grid", "tas.grid", "tos.grid", "sos.grid",
%       and "siconc.grid" in the current directory.

% Error check
if ~((isstring(folder)&&isscalar(folder)) || (ischar(folder)&&isrow(folder)))
    error('folder must be a string scalar');
end
folder = string(folder);
assert(isfolder(folder), 'Could not locate folder: %s', folder);

% Get the NetCDF files in the folder
contents = dir(folder);
files = string({contents.name})';
netcdf = endsWith(files, ".nc");
files = files(netcdf);
filepaths = fullfile(folder, files);

% Create metadata object
[lon, lat] = parameters.spatialPoints;
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