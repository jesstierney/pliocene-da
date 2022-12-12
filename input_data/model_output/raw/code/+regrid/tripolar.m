function[V, lon, lat] = tripolar(tlon, tlat, X, correctIPSL)
%% regrid.tripolar  Regrids a variable on a tripolar spatial grid
% ----------
%   V = regrid.tripolar(tlon, tlat, X)
%   Regrids a variable on a tripolar spatial grid to a curvilinear grid
%   at a fixed set of spatial points. Uses linear interpolation to regrid.
%   Does not extrapolate outside of the original grid - instead, values
%   outside the original grid are set to NaN.
%
%   The method is agnostic to -180:180 and 0:360 coordinate systems. The
%   input variable may follow either system. The spatial points of the
%   regridded variable are set by the function "parameters.spatialPoints".
%
%   [V, lon, lat] = regrid.tripolar(tlon, tlat, X)
%   Also returns the longitude and latitude points of the regridded
%   variable.
%
%   ... = regrid.tripolar(..., correctIPSL)
%   Indicate whether the method should strip NaN values from funnels in the
%   IPSL-CM6A tripolar grid.
% ----------
%   Inputs:
%       tlon (numeric matrix [nRows x nCols]): The longitude points of the initial 
%           tripolar spatial grid in decimal degrees. Values should be on
%           the interval -180:360
%       lat (numeric matrix [nRows x nCols]): The latitude points of the initial
%           tripolar spatial grid in decimal degrees.
%       X (numeric 3D array [nRows x nCols x nTime]): The variable to regrid.
%           Should be a numeric array with 3D dimensions. The order of
%           dimensions should be (spatial dimension 1 x spatial dimension 2 x time).
%       correctIPSL (scalar logical): If true, removes NaN values from the
%           locations of the funnels in the IPSL-CM6A tripolar grid. If
%           false, does not remove values. Default is false.
%
%   Outputs:
%       V (numeric 3D array [nLon x nLat x nTime]): The regridded
%           (curvilinear) variable
%       lon (numeric column vector [nLon]): The longitude points of the
%           (curvilinear) regridded variable in decimal degrees.
%       lat (numeric row vector [nLat]): The latitude points of the
%           (curvilinear) regridded variable in decimal degrees.

% Default
if ~exist('correctIPSL', 'var') || isempty(correctIPSL)
    correctIPSL = false;
end

% Error check
if any(tlon<-180,'all') || any(tlon>360,'all')
    error('longitudes must be on the interval -180:360');
elseif ndims(X)~=3
    error('X must be a 3D array');
elseif ~isequal(size(tlon), size(tlat))
    error('tlon and tlat must have the same size');
elseif size(tlon, 1) ~= size(X, 1)
    error('The number of rows of X must match the number of rows of tlon');
elseif size(tlon, 2) ~= size(X, 2)
    error('The number of columns of X must match the number of columns of tlon');
elseif ~isscalar(correctIPSL) || ~islogical(correctIPSL)
    error('correctIPSL must be a scalar logical');
end

% Place the longitudes on a 0-360 coordinate system
tlon = regrid.longitude(360, tlon);

% Get the 1x1 query points
[lon, lat] = parameters.spatialPoints;

% Get sizes
nLon = numel(lon);
nLat = numel(lat);
nTime = size(X, 3);

% Reshape as a collection of scattered points
tlon = tlon(:);
tlat = tlat(:);
X = reshape(X, [], nTime);

% Locate funnels for the IPSL correction
if correctIPSL
    nans = isnan(X(:,1));
    funnel =   (nans & tlat>84) ...
             | (nans & tlat>73 & tlon>70 & tlon<76) ...
             | (nans & tlat>73.5 & tlat<75 & tlon>252 & tlon<254) ...
             | (nans & tlat>76 & tlon>250 & tlon<256);

    % Remove points in the funnels
    tlon(funnel) = [];
    tlat(funnel) = [];
    X(funnel,:) = [];
end

% Remove NaN coordinates
nans = isnan(tlon) | isnan(tlat);
tlon(nans) = [];
tlat(nans) = [];
X(nans,:) = [];

% Preallocate the 1x1 regridded variable and get query point grid
V = NaN(nLon, nLat, nTime);
[qlon, qlat] = ndgrid(lon, lat);

% Use double data type for input points
tlon = double(tlon);
tlat = double(tlat);

% Disable duplicate point warning message (some models have duplicate
% points at the poles). Reset the warning when the function exits.
id = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
status = warning('query', id).state;
reset = onCleanup( @()warning(status, id) );
warning('off', id);

% Regrid each time step
for t = 1:nTime
    V(:,:,t) = griddata(tlon, tlat, X(:,t), qlon, qlat); %#ok<*GRIDD> 
end

% Check for longitudes that are all NaN (points along the edge of the 0-360
% grid). Regrid any NaN longitudes, and any longitudes in the outer half of
% the map
allnans = all(isnan(V), [2 3]);
nearEdge = lon<90 | lon>270;
regridRows = allnans | nearEdge;
regridLons = lon(regridRows);

% Convert the input variable and query points to a -180 to 180 longitude 
% coordinate system
lon180 = regrid.longitude(180, regridLons);
[qlon, qlat] = ndgrid(lon180, lat);
tlon = regrid.longitude(180, tlon);

% Re-query the missing longitudes on -180:180 (they should be near the
% center of the grid now, rather than the edge)
for t = 1:nTime
    V(regridRows,:,t) = griddata(tlon, tlat, X(:,t), qlon, qlat);
end

% Check that no longitudes are clipped
clipped = all(isnan(V), 2);
clipped = any(clipped, 3);
if any(clipped)
    error('There are clipped longitudes for which all values are NaN');
end

end