function[] = calculateR
%% calculateR  Calculates R (error-variance) values for proxy records
% ----------
%   calculateR
%   Calculates R (error-variances) for the proxy records. Calculates values
%   using 2 methods: (1) Using conservative, global values for each proxy
%   type, and (2) Applying the Osman scaling to the conservative values.
%   The conservative R values are saved in the NetCDF "R-conservative.nc",
%   and the values from the Osman scaling are saved in "R-osman.nc".
%
%   The global, conservative values for each proxy type are set in the
%   "parameters.globalR" function, and the scaling weights for the Osman
%   scaling are set in "parameters.osmanScaling".
% ----------
%   Outputs:
%       Creates two NetCDF files named "R-conservative.nc" and "R-osman.nc"
%       in the current directory.

% Load proxy metadata
proxies = gridfile('proxies').metadata.site;
IDs = proxies(:,1);
types = proxies(:,2);
nSite = numel(IDs);

% Identify proxy types
uk = types=="uk";
tex = types=="tex";
mg = types=="mg";

% Get the conservative, global R values
[Ruk, Rtex, Rmg] = parameters.globalR;

% Get the appropriate R value for each proxy record
R = NaN(nSite, 1);
R(uk) = Ruk;
R(tex) = Rtex;
R(mg) = Rmg;

% Export to NetCDF
file = "R-conservative.nc";
nSiteCols = 2;
nccreate(file, 'sites_columns', 'Dimensions', {'sites_columns',nSiteCols}, 'datatype', 'string', 'format', 'netcdf4');
nccreate(file, 'sites', 'Dimensions', {'sites',nSite,'sites_columns',nSiteCols}, 'datatype', 'string');
nccreate(file, 'R', 'Dimensions', {'sites',nSite}, 'datatype', 'double');

ncwriteatt(file, 'sites_columns', 'Description', 'The type of metadata stored along each column of site');
ncwriteatt(file, 'sites', 'Description', 'The proxy sites (and associated metadata)');
ncwriteatt(file, 'R', 'Description', 'Proxy error-variances generated using conservative, global values');

ncwrite(file, 'sites_columns', ["IDs","types"]);
ncwrite(file, 'sites', [IDs, types]);
ncwrite(file, 'R', R);

% Also compute R values with the scaling results from our LOO testing.
[ukScaling, texScaling, mgScaling] = parameters.plioScaling;
Ruk = Ruk / ukScaling;
Rtex = Rtex / texScaling;
Rmg = Rmg / mgScaling;

% Get the updated error variances
R(uk) = Ruk;
R(tex) = Rtex;
R(mg) = Rmg;

% Export to NetCDF
file = "R-plio.nc";
nSiteCols = 2;
nccreate(file, 'sites_columns', 'Dimensions', {'sites_columns',nSiteCols}, 'datatype', 'string', 'format', 'netcdf4');
nccreate(file, 'sites', 'Dimensions', {'sites',nSite,'sites_columns',nSiteCols}, 'datatype', 'string');
nccreate(file, 'R', 'Dimensions', {'sites',nSite}, 'datatype', 'double');

ncwriteatt(file, 'sites_columns', 'Description', 'The type of metadata stored along each column of site');
ncwriteatt(file, 'sites', 'Description', 'The proxy sites (and associated metadata)');
ncwriteatt(file, 'R', 'Description', 'Proxy error-variances generated via the Osman scaling');

ncwrite(file, 'sites_columns', ["IDs","types"]);
ncwrite(file, 'sites', [IDs, types]);
ncwrite(file, 'R', R);

end