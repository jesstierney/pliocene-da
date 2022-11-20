%% load  Functions that load data from raw climate model output files
% ----------
%   The load package contains Matlab functions used to load raw variables
%   from climate model output NetCDF files. The package includes functions for
%   variables stored on a monthly time step, as well as variables stored as
%   monthly climatologies. The package supports variables stored in a
%   single file, as well as variables stored across multiple files.
% ----------
%   Single Files:
%       monthly             - Load a monthly variable from a NetCDF file
%       climatology         - Load monthly climatologies from a NetCDF file
%
%   Multiple Files:
%       fileRange           - Loads a monthly variable stored over an iterative range of NetCDF files
%       fileYears           - Loads a monthly variable stored in multiple NetCDF files that span multiple years
%       climatologyRange    - Loads monthly climatologies stored over an iterative range of NetCDF files