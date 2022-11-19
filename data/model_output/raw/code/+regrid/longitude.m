function[varargout] = longitude(system, lon, X)
%% regrid.longitude  Matches a variable to a specific longitude coordinate system
% ----------
%   ... = regrid.longitude(system, ...)
%   ... = regrid.longitude(180, ...)
%   ... = regrid.longitude(360, ...)
%   Indicate whether the variable should be matched to a -180:180 or a
%   0:360 longitude coordinate system.
%
%   [V, lon] = regrid.longitude(system, lon, X)
%   Regrids a curvilinear variable on a particular longitude grid. The method is
%   agnostic to the original longitude coordinate system. Both -180:180 and
%   0:360 are allowed. Reorganizes the grid so that regridded longitude points are
%   sorted in ascending order. Also returns the longitude points of the
%   regridded variable (in the requested coordinate system).
%
%   lonArray = regrid.longitude(system, lonArray)
%   Converts an array of longitude coordinates to a particular coordinate system. 
%   Does not sort or reshape the coordinate array. This syntax is typically
%   used to place tripolar grid coordinates on a particular system without
%   affecting the layout of the tripolar spatial grid.
% ----------
%   Inputs:
%       system (180 | 360): Indicates the type of longitude coordinate
%           system that values should be mapped to. Use 180 for -180:180.
%           Use 360 for 0:360.
%       lon (numeric vector [nLon1]): The longitude points of the initial
%           grid in decimal degrees. Values should be on the interval -180:360.
%       X (numeric array [nLon1 x ?]): The variable to regrid. Longitude
%           should be the first dimension.
%       lonArray (numeric array): An array of longitude coordinates. Values
%           should be on the interval -180:360.
%
%   Outputs:
%       V (numeric array [nLon2 x ?]): The regridded variable. Follows the
%           requested longitude coordinate system in ascending order.
%       lon (numeric vector [nLon2]): The longitude coordinates of the
%           regridded variable in the requested coordinate system.
%       lonArray (numeric array): The array of longitude coordinates in the
%           requested longitude coordinate system

% Error check
assert(isnumeric(system) && isscalar(system), 'The longitude coordinate system must be a numeric scalar');
assert(system==180 || system==360, 'The longitude coordinate system must either be 180 or 360');
assert(all(lon>=-180,'all') && all(lon<=360,'all'), 'longitudes must be on the interval -180:360');

% Get the longitude conversion function
if system==180
    convertCoordinates = @convertTo180;
else
    convertCoordinates = @convertTo360;
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
function[lons] = convertTo360(lons)
negative = lons < 0;
lons(negative) = 360 + lons(negative);
end
function[lons] = convertTo180(lons)
west = lons>180;
lons(west) = lons(west) - 360;
end