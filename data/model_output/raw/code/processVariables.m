function[variables] = processVariables(variables, istripolar, files, lonNames, latNames, conversions, conversionTypes)

% Error check the inputs
assertVectorTypeN(variables, 'cell', NaN, 'variables');
nVars = numel(variables);
assertVectorTypeN(istripolar, 'logical', nVars, 'istripolar');
assertVectorTypeN(files, 'string', nVars, 'files');
assertVectorTypeN(lonNames, 'string', nVars, 'lonNames');
assertVectorTypeN(latNames, 'string', nVars, 'latNames');
assertVectorTypeN(conversions, 'numeric', nVars, 'conversions');
assertVectorTypeN(conversionTypes, 'string', nVars, 'conversionTypes');

% Validate conversions
assert(all(ismember(conversionTypes,["","+","*"])), 'The elements of conversionTypes must be "", "*", or "+"');
nans = isnan(conversions);
assert(all(conversionTypes(nans)==""), 'You must use "" as the conversion type for NaN conversions');
assert(~any(conversionTypes(~nans)==""), 'There are conversionTypes missing a conversion value');

% Error check each variable
for v = 1:nVars
    X = variables{v};
    assert(ndims(X)<=3, 'Variable %.f has more than 3 dimensions', v);
    nTime = size(X,3);
    assert(mod(nTime,12)==0, 'Variable %.f: The length of the third dimension must be a multiple of 12', v);

    % Get the climatology
    [nRows, nCols] = size(X, 1:2);
    X = reshape(X, nRows, nCols, 12, []);
    X = mean(X, 4);

    % Get latitude and longitude points
    lon = ncread(files(v), lonNames(v));
    lat = ncread(files(v), latNames(v));

    % Regrid tripolar
    if istripolar(v)
        lon = regrid.lon360(lon);
        X = regrid.tripolar(lon, lat, X);
    
    % Regrid curvilinear
    else
        [X, lon] = regrid.lon360(lon, X);
        X = regrid.curvilinear(lon, lat, X);
    end

    % Apply unit conversions
    if conversionTypes(v)=="+"
        X = X + conversions(v);
    elseif conversionTypes(v)=="*"
        X = X * conversions(v);
    end

    % Save processed variable
    variables{v} = X;
end

end

%% Utility function
function[] = assertVectorTypeN(input, type, N, name)
assert(isvector(input), '%s must be a vector', name);
assert(isa(input,type), '%s must be a "%s" data type', name, type);
if ~isnan(N)
    assert(length(input)==N, '%s must have %.f elements', name, N);
end
end