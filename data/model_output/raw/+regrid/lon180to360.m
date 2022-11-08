function[X, lon] = lon180to360(lon, X)
%% regrid.lon180to360  Regrids a curvilinear variable on a -180:180 longitude grid to a 0:360 grid
% ----------
%   [V, lon] = regrid.lon180to360(lon, X)
%   Regrids a curvilinear variable on a -180:180 longitude grid to a 0:360
%   grid. Reorganizes the grid so that regridded longitude points are
%   sorted in ascending order. Also returns the longitude points of the
%   regridded variable.
% ----------
%   Inputs:
%       lon (numeric vector [nLon1]): The longitude points of the initial
%           grid in decimal degrees. Should follow a -180:180 longitude
%           coordinate system.
%       X (numeric array [nLon1 x ?]): The variable to regrid. Longitude
%           should be the first dimension. The variable should be on a -180
%           to 180 longitude coordinate system.
%
%   Outputs:
%       V (numeric array [nLon2 x ?]): The regridded variable. Follows a
%           0:360 longitude coordinate system in ascending order.
%       lon (numeric vector [nLon2]): The longitude coordinates of the
%           regridded variable.

% Error check
if any(lon<-180, 'all') || any(lon>180,'all')
    error('longitudes must be -180:180');
elseif ~isvector('lon') || numel(lon)~=size(X,1)
    error('lon must be a vector with one element per row of X');
end

% Convert longitude coordinate system
negative = lon < 0;
lon(negative) = 360 + lon(negative);

% Arrange in sorted order
[lon, order] = sort(lon);
siz = size(X);
X = X(order,:);
X = reshape(X, siz);

end