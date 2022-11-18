function[lons, lats] = spatialPoints
%% parameters.spstialPoints  Return the spatial points for regridding climate model output
% ----------
%   [qlon, qlat] = regrid.points
%   Returns the spatial points for regridding cliamte model output. These
%   are the longitude and latitude points that a variable will be regridded
%   to.
% ----------
%   Outputs:
%       lons (numeric column vector): The longitude points that a variable
%           should be regridded to.
%       lats (numeric row vector): The latitude points that a variable
%           should be regridded to.

% Spatial points for the regridded model output
lons = (0.5:359.5)';
lats = -89.5:89.5;

end