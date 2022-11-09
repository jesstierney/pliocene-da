function[X, file] = fileRange(filePattern, variable, range, layer)

% Error check
assert(isstring(filePattern) && isscalar(filePattern), 'filePattern must be a string scalar');
assert(isstring(variable) && isscalar(variable), 'variable must be a string scalar');
assert(isnumeric(range) && isvector(range) && length(range)==2, 'range must be a numeric vector with two elements');
assert(range(1)<=range(2), 'The first element of range must be less than or equal to the second element');

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

% Check for the correct number of dimensions
nDims = numel(info.Variables(v).Dimensions);
if hasLayers
    assert(nDims==4, 'You cannot specify a layer because variable "%s" does not have 4 dimensions', variable);
else
    assert(nDims==3, 'You did not specify a layer, so variable "%s" must have 3 dimensions', variable);
end

% Check time has 12 elements
siz = [info.Variables(v).Dimensions.Length];
assert(siz(end)==12, 'The time dimension of variable "%s" does not have 12 elements per file', variable);

% Preallocate
nYears = range(2)-range(1)+1;
X = NaN(siz(1), siz(2), nYears*12);

% Get the time steps for each file
for k = range(1):range(2)
    times = (k-range(1))*12 + (1:12);
    file = sprintf(filePattern, k);

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