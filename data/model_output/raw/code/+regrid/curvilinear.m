function[V, qlon, qlat] = curvilinear(lon, lat, X)
%% regrid.curvilinear  Regrids a variable on a curvilinear spatial grid
% ----------
%   V = regrid.curvilinear(lon, lat, X)
%   Regrids a variable on a curvilinear spatial grid to a curvilinear grid
%   at a fixed set of spatial points. Uses linear interpolation to regrid.
%   Does not extrapolate outside of the original grid - instead, values
%   outside the original grid are set to NaN. 
%   
%   The method is agnostic to -180:180 and 0:360 coordinate systems. The
%   input variable may follow either system. The spatial points of the
%   regridded variable are set by the function "parameters.spatialPoints".
%
%   [V, lon, lat] = regrid.curvilinear(lon, lat, X)
%   Also returns the longitude and latitude points of the regridded
%   variable.
% ----------
%   Inputs:
%       lon (numeric vector [nLon1]): The longitude points of the initial 
%           curvilinear spatial grid in decimal degrees. Values should be on the
%           interval -180:360.
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
if any(lon<-180, 'all') || any(lon>360, 'all')
    error('longitudes must be on the interval -180:360');
elseif ndims(X)~=3
    error('X must be a 3D array');
elseif ~isvector(lon) || numel(lon)~=size(X,1)
    error('lon must be a vector with one element per row of X');
elseif ~isvector(lat) || numel(lat)~=size(X,2)
    error('lat must be a vector with one element per column of X');
end

% Place the variable on a 0-360 coordinate system
[X, lon] = regrid.longitude(360, lon, X);

% Get the spatial query points
[qlon, qlat] = parameters.spatialPoints;

% Get sizes
nLon = numel(qlon);
nLat = numel(qlat);
nTime = size(X, 3);

% Get the regridded variable in each time step
V = NaN(nLon, nLat, nTime);
for t = 1:nTime
    V(:,:,t) = interpn(lon, lat, X(:,:,t), qlon, qlat);
end

% Get any longitudes that are all NaN (points along the edge of the 0-360 grid)
allnans = all(isnan(V), [2 3]);
nanLons = qlon(allnans);

% If there are missing longitudes, convert the input variable and missing
% query points to a -180 to 180 longitude coordinate system
if any(allnans)
    qlon180 = regrid.longitude(180, nanLons);
    [X, lon] = regrid.longitude(180, lon, X);

    % Re-query the missing longitudes on -180:180 (they will be on the
    % center of the grid now, rather than the edge)
    for v = 1:nTime
        V(allnans,:,t) = interpn(lon, lat, X(:,:,t), qlon180, qlat);
    end
end

% Check that no longitudes are clipped
clipped = all(isnan(V), [2 3]);
if any(clipped)
    error('There are clipped longitudes for which all values are NaN');
end

end
