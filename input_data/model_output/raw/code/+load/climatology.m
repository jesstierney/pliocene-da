function[X] = climatology(file, variable, layer)
%% load.climatology  Loads monthly climatologies for a variable from a NetCDF file
% ----------
%   X = load.climatology(file, variable)
%   Loads a variable from a NetCDF file for the case where the NetCDF file 
%   stores the 12 monthly climatologies for the variable. The variable
%   should have 3 dimension with the 12 climatologies arranged along the
%   third dimension.
%
%   X = load.climatology(file, variable, layer)
%   Loads climatologies from a specific layer of the variable. The variable
%   should have 4 dimensions. Layers should be arranged along the third
%   dimension, and the 12 climatologies arranged along the fourth
%   dimension.
% ----------
%   Inputs:
%       file (string scalar): The name of a NetCDF file
%       variable (string scalar): The name of a variable in the NetCDF file
%       layer (scalar positive integer): The layer of the variable from
%           which to load monthly climatologies
%
%   Outputs:
%       X (numeric 3D array [nRows x nCols x 12]): The loaded monthly
%           climatologies

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