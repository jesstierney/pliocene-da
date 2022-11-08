function[qlon, qlat] = points
%% regrid.points  Return the query points for a regridding operation
% ----------
%   [qlon, qlat] = regrid.points
%   Returns the query points for a regridding operation. The query points
%   are the longitude and latitude points that a variable will be regridded
%   to.
% ----------
%   Outputs:
%       qlon (numeric column vector): The longitude points that a variable
%           should be regridded to.
%       qlat (numeric row vector): The latitude points that a variable
%           should be regridded to.

% Regrid to a 1x1 resolution
qlon = (0.5:359.5)';
qlat = -89.5:89.5;

end