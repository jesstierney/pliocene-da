function[X, file] = fileYears(filePattern, variable, startYears, stopYears, layer, keepAll)
%% load.fileYears  Loads a monthly variable stored in a set of NetCDF files that span multiple years
% ----------
%   [X, file] = load.fileYears(filePattern, variable, startYears, stopYears)
%   Loads data for a variable on a monthly time step that is stored across
%   several NetCDF files. Each NetCDF file holds output for a series of
%   successive years. The files should follow a common naming pattern that
%   includes the first and last year of output recorded in the file. Each 
%   file should hold data for all 12 months of each included year. The
%   variable in each file should have 3 dimensions with monthly timesteps
%   along the third dimension. Returns monthly data over the first 100
%   years of output. Also returns the name of the final file used to load
%   data.
%
%   [...] = load.fileYears(..., layer)
%   Loads data from a specific layer of the variable. The variable 
%   should have 4 dimensions. Layers should be arranged along the third
%   dimension, and the monthly timesteps arranged along the fourth
%   dimension.
%
%   [...] = load.fileYears(..., layer, keepAll)
%   Indicate whether to return monthly data over the first 100 years of output,
%   or whether to return all loaded data. Default is to return the first 100
%   years of output.
% ----------
%   Inputs:
%       filePattern (string scalar): The "sprintf" style naming pattern
%           used for the files. Should include two %f operands, used to
%           signify the first and last year associated with the file.
%       variable (string scalar): The name of a variable in the NetCDF file
%       startYears (vector, integers [nFiles]): The first year of recorded
%           output for each output file. From the second element onward,
%           each element should be exactly 1 greater than the previous stop
%           year.
%       stopYears (vector, integers [nFiles]): The final year of recorded
%           output for each file. 
%       layer (scalar positive integer): The layer of the variable from
%           which to load monthly data. If NaN or an empty array, does not
%           use a layer.
%       keepAll (scalar logical): If true, returns all loaded data. If
%           false (default), returns data from the first 100 years of output
%
%   Outputs:
%       X (numeric 3D array [nRows x nCols x 1200]): The loaded data
%       file (string scalar): The name of the final file used to load data

% Initial error check
assert(isstring(filePattern) && isscalar(filePattern), 'filePattern must be a string scalar');
assert(isstring(variable) && isscalar(variable), 'variable must be a string scalar');

% Validate start and stop years
assert(isnumeric(startYears) && isvector(startYears), 'startYears must be a numeric vector');
assert(isnumeric(stopYears) && isvector(stopYears), 'stopYears must be a numeric vector');

assert(all(mod(startYears,1)==0) && issorted(startYears), 'startYears must be a sorted vector of integers');
assert(all(mod(stopYears,1)==0) & issorted(stopYears), 'stopYears must be a sorted vector of integers');
assert(numel(startYears)==numel(stopYears), 'startYears and stopYears must have the same number of elements');

startYears = startYears(:);
stopYears = stopYears(:);
assert(all(startYears(2:end)==stopYears(1:end-1)+1), 'Each new startYear must be 1 higher than the previous stopYear');

% Default and error check keepAll
if exist('keepAll','var')
    assert(islogical(keepAll) && isscalar(keepAll), 'keepAll must be a logical scalar');
else
    keepAll = false;
end

% Parse the layer
hasLayers = false;
if exist('layer','var') && ~isempty(layer) && ~isnan(layer)
    assert(isnumeric(layer) && isscalar(layer) && mod(layer,1)==0 && layer>0, 'Layer must be a scalar positive integer');
    hasLayers = true;
end

% Check the first file exists
file = sprintf(filePattern, startYears(1), stopYears(1));
if isempty(which(file))
    error('Could not find file:\n%s', file);
end

% Check the variable is in the first file
info = ncinfo(file);
fileVariables = {info.Variables.Name};
[infile, v] = ismember(variable, fileVariables);
assert(infile, 'File\n%s\ndoes not have a "%s" variable', file, variable);

% Check for correct number of dimensions
nDims = numel(info.Variables(v).Dimensions);
if hasLayers
    assert(nDims==4, 'You cannot specify a layer because variable "%s" does not have 4 dimensions', variable);
else
    assert(nDims==3, 'You did not specify a layer, so variable "%s" must have 3 dimensions', variable);
end

% Preallocate
siz = [info.Variables(v).Dimensions.Length];
nYears = stopYears(end) - startYears(1) + 1;
X = NaN(siz(1), siz(2), nYears*12);

% Get the time steps for each file
for f = 1:numel(startYears)
    file = sprintf(filePattern, startYears(f), stopYears(f));
    nMonths = 12 * (stopYears(f)-startYears(f)+1);
    times = (startYears(f)-startYears(1))*12 + (1:nMonths);

    % Load
    if hasLayers
        start = [1 1 layer 1];
        count = [Inf Inf 1 Inf];
    else
        start = [1 1 1];
        count = [Inf Inf Inf];
    end
    X(:,:,times) = ncread(file, variable, start, count);
end

% Restrict to first 100 years
if ~keepAll
    X = X(:,:,1:1200);
end

end