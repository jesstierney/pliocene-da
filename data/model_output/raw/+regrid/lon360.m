function[X, lon] = lon360(lon, X)
%% regrid.lon360  Matches a curvilinear variable to a 0:360 grid
% ----------
%   [V, lon] = regrid.lon360(lon, X)
%   Regrids a curvilinear variable on a 0:360 longitude grid. The method is
%   agnostic to the original longitude coordinate system. Both -180:180 and
%   0:360 are allowed. Reorganizes the grid so that regridded longitude points are
%   sorted in ascending order. Also returns the 0:360 longitude points of the
%   regridded variable.
% ----------
%   Inputs:
%       lon (numeric vector [nLon1]): The longitude points of the initial
%           grid in decimal degrees. Values should be on the interval -180:360.
%       X (numeric array [nLon1 x ?]): The variable to regrid. Longitude
%           should be the first dimension.
%
%   Outputs:
%       V (numeric array [nLon2 x ?]): The regridded variable. Follows a
%           0:360 longitude coordinate system in ascending order.
%       lon (numeric vector [nLon2]): The 0:360 longitude coordinates of the
%           regridded variable.

% Error check
if any(lon<-180, 'all') || any(lon>360,'all')
    error('longitudes must be -180:360');
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