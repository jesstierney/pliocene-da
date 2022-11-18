%% regrid  Functions that map climate variables between different spatial grids
% ----------
%   The regrid package contains Matlab functions used to map climate
%   variables between different spatial grids. Specifcally, these functions
%   regrid variables onto a common curvilinear, longitude x latitude
%   spatial grid.
%
%   The resolution of the common spatial grid is determined by the spatial
%   points in the "parameters.spatialPoints" function. You can change the
%   resolution of the regridded climate model output by editing that
%   function.
% ----------
%   Regridding Functions:
%       tripolar    - Regrids a tripolar variable to a common curvilinear grid
%       curvilinear - Regrids a curvilinear variable to a common curvilinear grid
%       lon360      - Matches a curvilinear variable to a 0:360 longitude coordinate system