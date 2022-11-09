function[X] = climatology(file, variable, layer)

% Initial error check
assert(isstring(file) && isscalar(file), 'file must be a string scalar');
assert(isstring(variable) && isscalar(variable), 'variable must be a string scalar');
if isempty(which(file))
    error('Could not find file:\n%s', file);
end

% Parse the layer
hasLayers = false;
if exist('layer','var')
    assert(isnumeric(layer) && isscalar(layer) && mod(layer,1)==0 && layer>0, 'Layer must be a scalar positive integer');
    hasLayers = true;
end

% Check variable is in file
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

% Check time has 12 elements
siz = [info.Variables(v).Dimensions.Length];
assert(siz(end)==12, 'The time dimension of variable "%s" does not have 12 elements', variable);

% Load
if hasLayers
    start = [1 1 layer 1];
    count = [Inf Inf 1 12];
else
    start = [1 1 1];
    count = [Inf Inf 12];
end
X = ncread(file, variable, start, count);

% Remove singleton layers
if hasLayers
    X = reshape(X, siz(1), siz(2), 12);
end

end