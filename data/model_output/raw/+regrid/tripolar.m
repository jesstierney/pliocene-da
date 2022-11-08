function[V, qlon, qlat] = tripolar(tlon, tlat, X)
%% regrid.tripolar  Regrids a variable on a tripolar spatial grid
% ----------
%   V = regrid.tripolar(tlon, tlat, X)
%   Regrids a variable on a tripolar spatial grid to a curvilinear grid
%   at a fixed set of spatial points. Uses linear interpolation to regrid.
%   Does not extrapolate outside of the original grid - instead, values
%   outside the original grid are set to NaN.
%
%   [V, lon, lat] = regrid.curvilinear(tlon, tlat, X)
%   Also returns the longitude and latitude points of the regridded
%   variable.
% ----------
%   Inputs:
%       tlon (numeric matrix [nRows x nCols]): The longitude points of the initial 
%           tripolar spatial grid in decimal degrees.
%       lat (numeric matrix [nRows x nCols]): The latitude points of the initial
%           tripolar spatial grid in decimal degrees.
%       X (numeric 3D array [nRows x nCols x nTime]): The variable to regrid.
%           Should be a numeric array with 3D dimensions. The order of
%           dimensions should be (spatial dimension 1 x spatial dimension 2 x time).
%
%   Outputs:
%       V (numeric 3D array [nLon x nLat x nTime]): The regridded
%           (curvilinear) variable
%       lon (numeric column vector [nLon]): The longitude points of the
%           (curvilinear) regridded variable in decimal degrees.
%       lat (numeric row vector [nLat]): The latitude points of the
%           (curvilinear) regridded variable in decimal degrees.


% Error check
if any(tlon<0, 'all')
    error('longitudes must be 0-360');
elseif ndims(X)~=3
    error('X must be a 3D array');
elseif ~isequal(size(tlon), size(tlat))
    error('tlon and tlat must have the same size');
elseif size(tlon, 1) ~= size(X, 1)
    error('The number of rows of X must match the number of rows of tlon');
elseif size(tlon, 2) ~= size(X, 2)
    error('The number of columns of X must match the number of columns of tlon');
end

% Get the 1x1 query points
[qlon, qlat] = regrid.points;

% Get sizes
nLon = numel(qlon);
nLat = numel(qlat);
nTime = size(X, 3);

% Reshape as a collection of scattered points
tlon = tlon(:);
tlat = tlat(:);
X = reshape(X, [], nTime);

% Remove NaN coordinates
nans = isnan(tlon) | isnan(tlat);
tlon(nans) = [];
tlat(nans) = [];
X(nans,:) = [];

% Preallocate the 1x1 regridded variable and get query point grid
V = NaN(nLon, nLat, nTime);
[qlon, qlat] = ndgrid(qlon, qlat);

% Regrid each time step
for t = 1:nTime
    V(:,:,t) = griddata(tlon, tlat, X(:,t), qlon, qlat); %#ok<GRIDD> 
end

end