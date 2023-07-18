function[] = buildEnsemble(label, runs)
%% buildEnsemble  Builds an ensemble from a set of runs and saves the ensemble to a .ens file
% ----------
%   buildEnsemble(label, runs)
%   Builds a state vector ensemble from a collection of model runs. The
%   ensemble is saved in a .ens file in the current directory. The name of 
%   the .ens file will match the label provided for the ensemble.
% 
%   The state vector contains variables for the "pr", "tas", "tos", and 
%   "siconc" reconstruction targets for annual, DJF, and JJA seasonal means.
%   The names of the variables follow the naming convention: 
%       <climate variable>_<season>
%
%   As a reminder, variables are as follows:
%       pr - Total precipitation
%       tas - Near surface air temperature
%       tos - Sea surface temperature
%       sos - Sea surface salinity
%       siconc - Sea ice area percentage
%
%   Seasons are as follows:
%       annual - Annual mean
%       DJF    - Boreal Winter (December-January-February)
%       JJA    - Boreal Summer (June-July-August)
%
%   The state vector also includes monthly "tos" and "sos" variables, which
%   are used to run the PSMs. These variables are named "tos_monthly" and
%   "sos_monthly".
%
%   The ensemble will contain one ensemble member per indicated run. This
%   method will throw an error if a run is not in the gridfile, or if the
%   list of runs contains duplicate values.
% ----------
%   Inputs:
%       label (string scalar): A label for the ensemble. This label will be
%           used as the file name for the saved ".ens" file.
%       runs (string matrix [nRuns x 2]): Metadata for the runs that should
%           be included in the ensemble. The first column lists the climate
%           model associated with each run, and the second column lists the
%           experiment tags.
%
%   Outputs:
%       Creates a file named <label>.ens in the current directory. The file
%       holds the saved state vector ensemble.

% Error check
if ~((isstring(label)&&isscalar(label)) || (ischar(label)&&isrow(label)))
    error('label must be a string scalar');
end
assert(isstring(runs)&&ismatrix(runs)&&size(runs,2)==2, 'runs must be a string matrix with 2 columns');
uniqueRuns = unique(runs, 'rows');
assert(size(uniqueRuns,1)==size(runs,1), 'runs cannot contain duplicate rows');

% Get gridfiles
pr = gridfile("pr");
tas = gridfile("tas");
tos = gridfile("tos");
sos = gridfile("sos");
siconc = gridfile("siconc");

% Check each run is in the gridfile
allRuns = tos.metadata.run;
missing = ~ismember(runs, allRuns, 'rows');
if any(missing)
    missing = find(missing, 1);
    error('Run %.f is not in the gridfile\n\tModel: %s\n\tExperiment: %s', missing, runs(missing,1), runs(missing,2));
end

% Create state vector
sv = stateVector(label);

% Add variables for reconstruction targets
grids = [pr, tas, siconc];
variables = ["pr","tas","siconc"];
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
% Add annual tos and sos for export
sv = sv.add("tos_annual",tos);
sv = sv.design("tos_annual", 'time', 'state', 1:12);
sv = sv.mean("tos_annual", 'time');
%
sv = sv.add("sos_annual",sos);
sv = sv.design("sos_annual", 'time', 'state', 1:12);
sv = sv.mean("sos_annual", 'time');

% Select from pre-industrial runs
use = ismember(allRuns, runs, 'rows');
sv = sv.design(-1, 'run', 'ensemble', use);

% Build the ensemble
sv.build('all', 'sequential', true, 'file', label, 'overwrite', true);

end