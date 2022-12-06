function[deltas] = dGMST(piRun, plioRuns, seasonMonths)
%% dGMST  Computes delta GMST for pre-processed climate model output
% ----------
%   deltas = dGMST(piRun, plioRuns, seasonMonths)
%   Computes delta GMST from two pre-processed climate model output
%   files. GMST is calculated using a latitude-weighted, global mean over 
%   the tas (near surface air temperature) field. Calculates GMST over a
%   specified seasonal mean.
% ----------
%   Inputs:
%       piRun (string scalar): The run metadata for the preindustrial run.
%           Only a single run should be listed. This run will be used as
%           the background state for all input pliocene runs.
%       plioRuns (string vector [nRuns]): The run metadata for the Pliocene
%           runs. Can list metadata for multiple runs. Note that the delta
%           GMST values for all input Pliocene runs are calculated using
%           the same preindustrial background state.
%       seasonMonths (numeric vector): Indicates the months to use for a
%           seasonal mean.Elements should be integers on the
%            interval 1:12. For example, use 1:12 for an annual mean,
%            [12 1 2] for DJF, and [6 7 8] for JJA.
%
%   Outputs:
%       deltas (numeric vector [nRuns]): Delta GMST values for each
%           Pliocene run.

% Get the file names
piFile = runs2files(piRun);
plioFiles = runs2files(plioRuns);

% Preallocate delta GMST values
nRuns = numel(plioFiles);
deltas = NaN(nRuns, 1);

% Get GMST values for each run
Tpi = gmst(piFile, seasonMonths);
for r = 1:nRuns
    Tplio = gmst(plioFiles(r), seasonMonths);

    % Compute deltas
    deltas(r) = Tplio - Tpi;
end

end

%% Utilities
function[files] = runs2files(runs)
files = strcat(runs(:,1), "_", runs(:,2), ".nc");
end
function[T] = gmst(file, seasonMonths)

% Load the variable
if ~endsWith(file, '.nc')
    file = strcat(file, '.nc');
end
T = ncread(file, 'tas');

% Get the requested seasonal mean
T = T(:,:,seasonMonths);
T = mean(T, 3);

% Take longitude mean and note NaN points
T = mean(T,1,'omitnan');
nans = isnan(T);

% Take latitude-weighted spatial mean
lat = ncread(file, 'lat');
latWeights = cosd(lat');
latWeights(nans) = NaN;
T = sum(latWeights.*T,'omitnan') / sum(latWeights,'omitnan');

end