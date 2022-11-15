function[] = buildEnsemble(label, experiments)

% Create state vector
sv = stateVector(label);

% Get gridfiles
pr = gridfile("pr");
tas = gridfile("tas");
tos = gridfile("tos");
sos = gridfile("sos");
siconc = gridfile("siconc");

% Add variables for reconstruction targets
grids = [pr, tas, tos, siconc];
variables = ["pr","tas","tos","siconc"];
seasons = ["annual","DJF","JJA"];
stateIndices = {1:12, [12 1 2], 6:8};

% Add a state vector variable for each climate-variable/season combination.
for v = 1:numel(variables)
    for s = 1:numel(seasons)
        name = strcat(variables(v),"_",seasons(s));
        sv = sv.add(name, grids(v));

        % Take a mean over the appropriate season
        sv = sv.design(name, 'time', 'state', stateIndices{s});
        sv = sv.mean(name, 'time');
    end
end

% Also add monthly SST and SSS for the PSMs
sv = sv.add("tos_monthly", tos);
sv = sv.add("sos_monthly", sos);

% Select from pre-industrial runs
allExperiments = tos.metadata.run(:,2);
use = ismember(allExperiments, experiments);
sv = sv.design(-1, 'run', 'ensemble', use);

% Build the ensemble
sv.build('all', 'sequential', true, 'file', label, 'overwrite', true);

end