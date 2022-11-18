function[files, pr, tas, tos, sos, siconc] = validateUnits
%% validateUnits  Returns the maximum value of each dataset
% ----------
%   [files, pr, tas, tos, sos, siconc] = validateUnits
%   Scans through the current directory and locates all NetCDF files. Reads
%   the "pr", "tas", "tos", "sos", and "siconc" variables from each NetCDF
%   and determines the maximum value of each variable. Returns the names of
%   the checked files, and the maximum values of each variable in each
%   file.
%
%   The outputs of this function can be used to validate that the variables
%   are in the same units in each pre-processed output file. Note that this
%   function runs on files in the current directory. The only NetCDF files
%   in the directory should be the pre-processed model output files, and
%   each NetCDF file must end with a ".nc" extension.
% ----------
%   Outputs:
%       files (string vector): The names of the checked NetCDF files
%       pr (numeric vector): The maximum pr value in each file
%       tas (numeric vector): The maximum tas value in each file
%       tos (numeric vector): The maximum tos value in each file
%       sos (numeric vector): The maximum sos value in each file
%       siconc (numeric vector): The maximum siconc      value in each file

% Get the NetCDF files in the directory
contents = dir;
names = string({contents.name});
netcdf = endsWith(names, ".nc");
files = names(netcdf);

% Preallocate
nFiles = numel(files);
pr = NaN(nFiles, 1);
tas = NaN(nFiles, 1);
tos = NaN(nFiles, 1);
sos = NaN(nFiles, 1);
siconc = NaN(nFiles, 1);

% Iterate through files
for f = 1:nFiles
    file = files(f);

    % Get the maximum value for each variable
    pr(f) = getMax(file, "pr");
    tas(f) = getMax(file, "tas");
    tos(f) = getMax(file, "tos");
    sos(f) = getMax(file, "sos");
    siconc(f) = getMax(file, "siconc");
end

end

%% Utility function
function[Xmax] = getMax(file, variable)
X = ncread(file, variable);
Xmax = max(X, [], 'all');
end
