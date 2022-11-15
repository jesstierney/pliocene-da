function[output, ensMeta] = assimilatePi

%% Observations

% Load the proxy observations
proxies = gridfile('proxies');
Y = proxies.load;

% Take natural log of Mg/Ca proxies
types = proxies.metadata.site(:,2);
mg = types=="mg";
Y(mg,:) = log( Y(mg,:) );

%% Prior

% Get prior
ens = ensemble('preindustrial');

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

        % Also need to correct for true zeros
        correction = Xv==0;
        Xv(correction) = NaN;

        % Replace precipitation zeros with the minimum non-zero value.
        % (Sea ice zeros are usually over land and can remain NaN)
        if startsWith(variable, "pr")
            Xv(correction) = NaN;
            minVal = min(Xv, [], 'all', 'omitnan');
            Xv(correction) = minVal;
        end

        % Apply natural log to approximate Gaussian distribution
        X(rows,:) = log(Xv);
    end
end

%% Estimates and R

% Load the estimates
Ye = ncread('preindustrial-estimates.nc', 'Ye');

% Load R
R = ncread('R-conservative.nc', 'R');


%% Assimilate

% Initialize Kalman filter and provide essential parameters
kf = kalmanFilter('preindustrial');
kf = kf.observations(Y);
kf = kf.prior(X);
kf = kf.estimates(Ye);
kf = kf.uncertainties(R);

% Run the filter
output = kf.run;

% Reverse transform precipitation and sea ice
for v = 1:numel(variables)
    variable = variables(v);
    if startsWith(variable, ["pr","siconc"])
        rows = ensMeta.find(variable);
        Av = output.Amean(rows,:);
        output.Amean(rows,:) = exp( Av );
    end
end

end