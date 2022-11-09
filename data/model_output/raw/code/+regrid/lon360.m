function[varargout] = lon360(lon, X)
%% regrid.lon360  Matches a curvilinear variable to a 0:360 grid
% ----------
%   [V, lon] = regrid.lon360(lon, X)
%   Regrids a curvilinear variable on a 0:360 longitude grid. The method is
%   agnostic to the original longitude coordinate system. Both -180:180 and
%   0:360 are allowed. Reorganizes the grid so that regridded longitude points are
%   sorted in ascending order. Also returns the 0:360 longitude points of the
%   regridded variable.
%
%   lonArray = regrid.lon360(lonArray)
%   Converts an array of longitude coordinates to a 0:360 coordinate system. 
%   Does not sort or reshape the coordinate array. This syntax is typically
%   used to place tripolar grid coordinates on a 0:360 system without
%   affecting the layout of the tripolar spatial grid.
% ----------
%   Inputs:
%       lon (numeric vector [nLon1]): The longitude points of the initial
%           grid in decimal degrees. Values should be on the interval -180:360.
%       X (numeric array [nLon1 x ?]): The variable to regrid. Longitude
%           should be the first dimension.
%       lonArray (numeric array): An array of longitude coordinates.
%
%   Outputs:
%       V (numeric array [nLon2 x ?]): The regridded variable. Follows a
%           0:360 longitude coordinate system in ascending order.
%       lon (numeric vector [nLon2]): The 0:360 longitude coordinates of the
%           regridded variable.
%       lonArray (numeric array): The array of longitude coordinates on a
%           0:360 coordinate system.

% Error check lons
if any(lon<-180, 'all') || any(lon>360,'all')
    error('longitudes must be -180:360');
end

% Update coordinate system if there is no climate variable
if ~exist('X','var')
    varargout = {convertCoordinates(lon)};

% Error check for regridding
elseif ~isvector('lon') || numel(lon)~=size(X,1)
    error('lon must be a vector with one element per row of X');

% Regrid. Start by converting longitude coordinate system
else
    lon = convertCoordinates(lon);

    % Arrange in sorted order
    [lon, order] = sort(lon);
    siz = size(X);
    X = X(order,:);
    X = reshape(X, siz);

    % Set output
    varargout = {X, lon};
end

end

%% Utility function
function[lons] = convertCoordinates(lons)
negative = lons < 0;
lons(negative) = 360 + lons(negative);
end