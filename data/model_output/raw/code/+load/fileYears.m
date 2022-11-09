function[X, file] = fileYears(filePattern, variable, startYears, stopYears, layer)

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

% Parse the layer
hasLayers = false;
if exist('layer','var')
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
    times = (stopYears(f)-startYears(1))*12 + (1:nMonths);

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
X = X(:,:,1:1200);

end