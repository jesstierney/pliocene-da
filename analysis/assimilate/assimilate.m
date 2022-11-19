function[output, ensMeta] = assimilate(label, age, estimatesLabel, Rlabel)

%% Observations

% Load the proxy observations
proxies = gridfile('proxies');
meta = proxies.metadata;
timeSlice = meta.time == age;
Y = proxies.load(["site","time"], {[],timeSlice});

% Take natural log of Mg/Ca proxies
types = meta.site(:,2);
mg = types=="mg";
Y(mg,:) = log( Y(mg,:) );

%% Estimates and R

% Load the estimates
YeFile = strcat(estimatesLabel, '-estimates.nc');
Ye = ncread(YeFile, 'Ye');

% Load R
Rfile = strcat('R-', Rlabel, '.nc');
R = ncread(Rfile, 'R');

%% Prior

% Get prior
ensembleName = ncread(YeFile, 'ensemble_name');
ens = ensemble(ensembleName);

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
        if startsWith(variable, "pr")
            Xv(correction) = NaN;
            minVal = min(Xv, [], 'all', 'omitnan');
            Xv(correction) = minVal;

            % Then apply a natural-log transformation
            X(rows,:) = log(Xv);

        % Apply a logit transformation to sea ice
        % (Sea ice zeros are usually over land and can remain NaN)
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

% Save Amean and metadata
Amean = output.Amean;
file = strcat(label, '-assimilation');
save(file, 'Amean', 'ensMeta', 'age');

end