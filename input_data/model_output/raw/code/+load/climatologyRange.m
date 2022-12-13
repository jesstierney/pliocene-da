function[X, file] = climatologyRange(filePattern, variable, layer)
%% load.climatologyRange  Loads monthly climatologies for a variable from an iterative range of files
% ----------
%   [X, file] = load.climatologyRange(filePattern, variable)
%   Loads monthly climatologies for a variable from an iterative range of
%   NetCDF file. Each individual file should hold data for 1 monthly
%   climatology. The files should follow a common naming pattern in which
%   the file name includes an integer from 1 to 12. The variable in each
%   file should have 3 dimensions and the third dimension should hold the
%   single monthly climatology. Returns the loaded climatologies and the
%   name of the final file used to load data.
%
%   [...] = load.climatologyRange(..., layer)
%   Loads data from a specific layer of the variable. The variable
%   should have 4 dimensions. Layers should be arranged along the third
%   dimension, and the single climatology along the fourth dimension.
% ----------
%   Inputs:
%       filePattern (string scalar): The "sprintf" style naming pattern
%           used for the files. Should include one %f operands, used to
%           signify the month (from 1 to 12) associated with the file.
%       variable (string scalar): The name of a variable in the NetCDF file
%       layer (scalar positive integer): The layer of the variable from
%           which to load monthly climatologies
%
%   Outputs:
%       X (numeric 3D array [nRows x nCols x 12]): The loaded climatologies
%       file (string scalar): The name of the final file used to load data

% Error check
assert(isstring(filePattern) && isscalar(filePattern), 'filePattern must be a string scalar');
assert(isstring(variable) && isscalar(variable), 'variable must be a string scalar');

% Parse the layer
hasLayers = false;
if exist('layer','var')
    assert(isnumeric(layer) && isscalar(layer) && mod(layer,1)==0 && layer>0, 'Layer must be a scalar positive integer');
    hasLayers = true;
end

% Check the first file exists
file = sprintf(filePattern, 1);
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

% Check time has 1 element
siz = [info.Variables(v).Dimensions.Length];
assert(siz(end)==1, 'The time dimension of variable "%s" does not have 1 element per file', variable);

% Preallocate
X = NaN(siz(1), siz(2), 12);

% Get each file
for month = 1:12
    file = sprintf(filePattern, month);

    % Load
    if hasLayers
        start = [1 1 layer 1];
        count = [Inf Inf 1 Inf];
    else
        start = [1 1 1];
        count = [Inf Inf Inf];
    end
    X(:,:,month) = ncread(file, variable, start, count);
end

end