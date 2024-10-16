function[Y, Ye, R, members, YeFile] = loadCoreInputsPV(estimatesLabel, Rlabel, runs, sites)
%% loadCoreInputs  Loads the Y, Ye, and R values for an assimilation
% ----------
%   [Y, Ye, R, members, YeFile] = loadCoreInputs(estimatesLabel, Rlabel, runs, sites)
%   Loads the Y, Ye, and R values for an assimilation. Loads proxy records
%   in the time slice associated with the estimates (the associated time
%   slice is saved in the NetCDF file for the estimates). Restricts values
%   to any user-specified sites, or selects all sites if none are
%   specified. Applies a natural log transform to any Mg/Ca records in the
%   observations (Y).
% 
%   Also parses the ensemble members to use for the assimilation. If no
%   climate model runs are indicated, selects all available ensemble
%   members. Otherwise, locates ensemble members that match a set of
%   specified climate model runs. Throws an error if any climate model runs
%   are not in the ensemble.
% ----------
%   Inputs:
%       estimatesLabel (string scalar): The label of a set of estimates to
%           use for the assimilation. This is the first part of a proxy
%           estimates NetCDF file (the part of the file name before
%           "_estimates.nc")
%       Rlabel (string scalar): Indicates the type of R values to use.
%           Either "conservative" or "osman"
%       runs ([] | string matrix [nUserRuns x 2]): Indicates the climate model runs
%           that should be used as ensemble members in the assimilation. If
%           empty, select all available ensemble members. Otherwise, these
%           values should be from the "run" metadata of the ensemble.
%           The first column is the climate model associated with each run,
%           and the second column is the experimental tag.
%       sites ([] | logical vector [nSite]): A logical vector indicating the 
%           proxy sites that should be included in the assimilation.
%           If an empty array, uses all available sites.
%
%   Outputs:
%       Y (numeric vector [nSite]): The proxy observations in the time
%           slice associated with the estimates
%       Ye (numeric matrix [nSite x nMembers]): Proxy estimates
%       R (numeric vector [nSite]): Proxy error variances (uncertainties)
%       members (vector, logical | linear indices): Indicates the ensemble
%           members that should be used for assimilation
%       YeFile (string scalar): The name of the NetCDF file holding the estimates

% Get proxy gridfile and metadata
proxies = gridfile('proxiesPlioVar');
meta = proxies.metadata;
nSite = size(meta.site, 1);

% Default and error check sites
if isempty(sites)
    sites = 1:nSite;
else
    assert(islogical(sites) && isvector(sites) && length(sites)==nSite, ...
        'sites must be a logical vector with %.f elements', nSite);
end

% Load the estimates and associated time slice
YeFile = strcat(estimatesLabel, '_estimates.nc');
age = ncread(YeFile, 'time');
Ye = ncread(YeFile, 'Ye');
Ye = Ye(sites,:);

% Load R
Rfile = strcat('R-', Rlabel, '.nc');
R = ncread(Rfile, 'R');
R = R(sites);

% Load the proxy observations
proxies = gridfile('proxiesPlioVar');
meta = proxies.metadata;
timeSlice = meta.time == age;
Y = proxies.load(["site","time"], {sites,timeSlice});

% Take natural log of Mg/Ca proxies
types = meta.site(sites,2);
mg = types=="mg";
Y(mg,:) = log( Y(mg,:) );

% Parse and error check the ensemble members
nMembers = size(Ye,2);
allRuns = ncread(YeFile, 'members');
if isempty(runs)
    members = 1:nMembers;
else
    missing = ~ismember(runs, allRuns, 'rows');
    if any(missing)
        missing = find(missing,1);
        error('run %.f is not in the ensemble\n\tModel: %s\n\tExperiment: %s', missing, runs(missing,1), runs(missing,2));
    end
    members = ismember(allRuns, runs, 'rows');
end

end