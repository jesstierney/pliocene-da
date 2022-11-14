function[] = exportNetCDF(file, pr, tas, tos, sos, siconc)
%% exportNetCDF  Export pre-processed climate model output to NetCDF
% ----------
%   exportNetCDF(file, pr, tas, tos, sos, siconc)
%   Exports the pre-processed climate model variables to NetCDF. Includes
%   spatial grid metadata, time metadata, and attributes indicating the
%   units of all variables. Writes the NetCDF file to the current
%   directory.
% ----------
%   Inputs:
%       file (string scalar | char row vector): The name of the new NetCDF file.
%       pr (numeric 3D array [nLon x nLat x 12]): The regridded, monthly 
%           precipitation climatologies in units of mm/day
%       tas (numeric 3D array [nLon x nLat x 12]): The regridded, monthly 
%           near-surface air temperature climatologies in units of Kelvin
%       tos (numeric 3D array [nLon x nLat x 12]): The regridded, monthly 
%           sea surface temperature climatologies in units of Celsius
%       sos (numeric 3D array [nLon x nLat x 12]): The regridded, monthly 
%           sea surface salinity climatologies in units of g/kg
%       siconc (numeric 3D array [nLon x nLat x 12]): The regridded, monthly 
%           sea ice area fraction climatologies in units of percentage
%
%   Outputs:
%       Creates a NetCDF file matching the file name in the current
%       directory

% Setup
month = 1:12;
[lon, lat] = regrid.points;
nLon = numel(lon);
nLat = numel(lat);

% Create NetCDF variables
nccreate(file, 'lat', 'Dimensions', {'lat', nLat});
nccreate(file, 'lon', 'Dimensions', {'lon', nLon});
nccreate(file, 'month', 'Dimensions', {'month', 12});
nccreate(file, 'pr', 'Dimensions', {'lon', nLon, 'lat', nLat, 'month', 12}, 'Datatype', class(pr));
nccreate(file, 'tas', 'Dimensions', {'lon', nLon, 'lat', nLat, 'month', 12}, 'Datatype', class(tas));
nccreate(file, 'tos', 'Dimensions', {'lon', nLon, 'lat', nLat, 'month', 12}, 'Datatype', class(tos));
nccreate(file, 'sos', 'Dimensions', {'lon', nLon, 'lat', nLat, 'month', 12}, 'Datatype', class(sos));
nccreate(file, 'siconc', 'Dimensions', {'lon', nLon, 'lat', nLat, 'month', 12}, 'Datatype', class(siconc));

% Write variable units
ncwriteatt(file, 'lat', 'Units', 'Decimal Degrees North');
ncwriteatt(file, 'lon', 'Units', 'Decimal Degrees East');
ncwriteatt(file, 'month', 'Units', 'Calendar Month');
ncwriteatt(file, 'pr', 'Units', "mm / day");
ncwriteatt(file, 'tas', 'Units', "Kelvin");
ncwriteatt(file, 'tos', 'Units', "Celsius");
ncwriteatt(file, 'sos', 'Units', "g / kg");
ncwriteatt(file, 'sos', 'Units_Equivalent', "psu");
ncwriteatt(file, 'siconc', 'Units', "Percent");
ncwriteatt(file, 'siconc', 'Units_Range', "0 - 100%");

% Write variable descriptions
ncwriteatt(file, 'pr', 'Description', 'Total precipitation');
ncwriteatt(file, 'tas', 'Description', 'Near surface (usually 2m) air temperature');
ncwriteatt(file, 'tos', 'Description', 'Sea surface temperature');
ncwriteatt(file, 'sos', 'Description', 'Sea surface salinity');
ncwriteatt(file, 'siconc', 'Description', 'Sea ice area percentage');

% Write variables
ncwrite(file, 'lat', lat);
ncwrite(file, 'lon', lon);
ncwrite(file, 'month', month);
ncwrite(file, 'pr', pr);
ncwrite(file, 'tas', tas);
ncwrite(file, 'tos', tos);
ncwrite(file, 'sos', sos);
ncwrite(file, 'siconc', siconc);

end