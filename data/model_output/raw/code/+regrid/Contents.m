%% regrid  Functions that map climate variables between different spatial grids
% ----------
%   The regrid package contains Matlab functions used to map climate
%   variables between different spatial grids. Specifcally, these functions
%   regrid variables onto a common curvilinear, longitude x latitude
%   spatial grid.
%
%   The regrid package is also used to set the resolution of the final
%   spatial grid when regridding climate model variables for assimilation.
%   Currently, the package regrids variables to a 1x1 (longitude x latitude) 
%   resolution. However, you can change the resolution of the regridded
%   variables by editing the "regrid.points" function.
% ----------
%   Parameter Functions:
%       points      - Sets the query points (resolution) of regridded climate variables
%
%   Regridding Functions:
%       tripolar    - Regrids a tripolar variable to a common curvilinear grid
%       curvilinear - Regrids a curvilinear variable to a common curvilinear grid
%       lon360      - Matches a curvilinear variable to a 0:360 longitude coordinate system