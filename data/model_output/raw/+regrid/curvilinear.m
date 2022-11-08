function[V, qlon, qlat] = curvilinear(lon, lat, X)
%% regrid.curvilinear  Regrids a variable on a curvilinear spatial grid
% ----------
%   V = regrid.curvilinear(lon, lat, X)
%   Regrids a variable on a curvilinear spatial grid to a curvilinear grid
%   at a fixed set of spatial points. Uses linear interpolation to regrid.
%   Does not extrapolate outside of the original grid - instead, values
%   outside the original grid are set to NaN.
%
%   [V, lon, lat] = regrid.curvilinear(lon, lat, X)
%   Also returns the longitude and latitude points of the regridded
%   variable.
% ----------
%   Inputs:
%       lon (numeric vector [nLon1]): The longitude points of the initial 
%           curvilinear spatial grid in decimal degrees.
%       lat (numeric vector [nLat1]): The latitude points of the initial
%           curvilinear spatial grid in decimal degrees.
%       X (numeric 3D array [nLon1 x nLat1 x nTime]): The variable to regrid.
%           Should be a numeric array with 3D dimensions. The order of
%           dimensions should be (longitude x latitude x time).
%
%   Outputs:
%       V (numeric 3D array [nLon2 x nLat2 x nTime]): The regridded
%           (curvilinear) variable
%       lon (numeric column vector [nLon2]): The longitude points of the
%           (curvilinear) regridded variable in decimal degrees.
%       lat (numeric row vector [nLat2]): The latitude points of the
%           (curvilinear) regridded variable in decimal degrees.

% Error check
if any(lon<0, 'all')
    error('longitudes must be 0-360');
elseif ndims(X)~=3
    error('X must be a 3D array');
elseif ~isvector(lon) || numel(lon)~=size(X,1)
    error('lon must be a vector with one element per row of X');
elseif ~isvector(lat) || numel(lat)~=size(X,2)
    error('lat must be a vector with one element per column of X');
end

% Get the 1x1 query points
[qlon, qlat] = regrid.points;

% Get sizes
nLon = numel(qlon);
nLat = numel(qlat);
nTime = size(X, 3);

% Get the regridded variable in each time step
V = NaN(nLon, nLat, nTime);
for t = 1:nTime
    V(:,:,t) = interpn(lon, lat, X(:,:,t), qlon, qlat);
end

end
