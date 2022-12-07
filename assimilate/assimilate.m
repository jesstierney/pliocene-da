function[] = assimilate(label, estimatesLabel, Rlabel, runs, sites)
%% assimilate  Runs an assimilation for a particular time-slice
% ----------
%   assimilate(label, estimatesLabel, Rlabel)
%   Runs an assimilation for a particular time slice using DASH. Saves the
%   outputs to a .mat file in the current directory. The name of the file
%   will match the pattern "<label>_assimilation.mat"
%
%   Runs the assimilation for a single time slice. Proxy observations are
%   only loaded for the time slice indicated by the "age" input. This age
%   should match one of the time metadata values in "proxies.nc".
%   Proxy observations are compared to the estimates indicated by the
%   third input. Estimates will be loaded from the NetCDF file with the
%   matching label. The ensemble for the assimilation is determined using
%   the metadata in the proxy estimates NetCDF file. Uses the R values 
%   (error variances) indicated by the fourth input. R values are read from
%   the R-values NetCDF file matching this label.
%
%   Before running the Kalman filter, the method applies a (natural) log
%   transform to the Mg/Ca proxies so that they match the log-estimates
%   produced by BayMAG. The function also transforms precipitation (pr) and
%   sea ice (siconc) reconstruction targets prior to assimilation so that
%   they more closely resemble a Gaussian distribution. The function
%   applies a natural log transform to precipitation, and a logit transform
%   to sea ice. The reverse transformations are applied to the assimilated
%   variables before they are saved in the .mat files.
%
%   assimilate(..., runs)
%   Runs the assimilation using specific ensemble members.
%
%   assimilate(..., runs, sites)
%   Runs the assimilation using specific proxy sites.
% ----------
%   Inputs:
%       label (string scalar): A label for the assimilation. The name of
%           the saved .mat file will follow the pattern "<label>_assimilation.mat"
%       estimatesLabel (string scalar): The label of a set of estimates to
%           use for the assimilation. This is the first part of a proxy
%           estimates NetCDF file (the part of the file name before
%           "_estimates.nc")
%       Rlabel (string scalar): Indicates the type of R values to use.
%           Either "conservative" or "osman"
%       runs (string matrix [nRuns x 2]): Indicates the climate model runs
%           that should be used as ensemble members in the assimilation.
%           These values should be from the "run" metadata of the ensemble.
%           The first column is the climate model associated with each run,
%           and the second column is the experimental tag. If not
%           specified, uses all available runs.
%       sites (logical vector [nSite]): A logical vector indicating the 
%           proxy sites that should be included in the assimilation.
%           If not specified, uses all available sites.
%
%   Outputs:
%       Creates a file named "<label>_assimilation.mat" in the current
%       directory.

%% Initial setup

% Defaults for optional inputs
if ~exist('runs','var')
    runs = [];
end
if ~exist('sites','var')
    sites = [];
end

% Load observations, estimates, and uncertainties
[Y, Ye, R, members, YeFile] = loadCoreInputs(estimatesLabel, Rlabel, runs, sites);

% Build the ensemble object for the prior.
ensembleName = ncread(YeFile, 'ensemble_name');
ens = ensemble(ensembleName);

% Limit the prior and estimates to the indicated ensemble members
ens = ens.useMembers(members);
Ye = Ye(:,members);


%% Design the prior

% Don't bother assimilating variables that are only used to run the PSMs
variables = ens.variables;
remove = ismember(variables, ["tos_monthly","sos_monthly"]);
variables(remove) = [];
ens = ens.useVariables(variables);

% Load reconstruction targets
[X, ensMeta] = ens.load;

% Locate Precipitation and Sea Ice variables
for v = 1:numel(variables)
    variable = variables(v);
    if startsWith(variable, ["pr","siconc"])
        rows = ensMeta.find(variable);
        Xv = X(rows,:);

        % Remove small negative values resulting from rounding errors
        negative = Xv < 0;
        Xv(negative) = 0;

        % Correct for true zeros by replacing with minimum non-zero value
        iszero = Xv==0;
        minVal = min(Xv(~iszero), [], 'all');
        Xv(iszero) = minVal;

        % Apply a natural-log transformation to precipitation
        if startsWith(variable, "pr")
            X(rows,:) = log(Xv);

        % Apply a logit transformation to sea ice
        else
            Xv = Xv ./ 100;
            X(rows,:) = log( Xv./(1-Xv) );
        end
    end
end


%% Assimilate

% Initialize Kalman filter and provide essential parameters
kf = kalmanFilter(label);
kf = kf.observations(Y);
kf = kf.prior(X);
kf = kf.estimates(Ye);
kf = kf.uncertainties(R);

% Run the filter
output = kf.run;

% Locate precipitation and sea ice variables
for v = 1:numel(variables)
    variable = variables(v);
    if startsWith(variable, ["pr","siconc"])
        rows = ensMeta.find(variable);
        Av = output.Amean(rows,:);

        % Apply reverse transformations from Gaussian
        Av = exp(Av);
        if startsWith(variable, "pr")
            output.Amean(rows,:) = Av;
        else           
            output.Amean(rows,:) = 100 * (Av ./ (1+Av));
        end
    end
end

% Get output fields
Amean = output.Amean;
age = ncread(YeFile, 'time');
if isempty(sites)
    sites = true(size(Y));
end

% Save output
file = strcat(label, '_assimilation');
save(file, 'Amean', 'ensMeta', 'age', 'estimatesLabel', 'Rlabel', 'sites');

end