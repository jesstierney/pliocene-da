function[models, coordinates, months] = buildPSMs(age, latName, lonName)
%% buildPSMs  Builds the DASH PSMs for the proxy sites in a particular time slice
% ----------
%   [models, coordinates, months] = buildPSMs(age, latName, lonName)
%   Builds the forward models for the proxy sites for a particular time
%   slice. BAYMAG PSMs will use a sea-water correction for the given age.
%   All PSMs will use the indicated paleo-coordinates. Also determines the
%   seasonal window for each site.
% ----------
%   Inputs:
%       age (numeric scalar): The time slice for which to build PSMs. Should
%           match one of the time slices in "proxies.nc". Units are Ma
%       latName (string scalar): The name of the column of proxy site
%           metadata to use as latitude coordinates.
%       lonName (string scalar): The name of the column of proxy site
%           metadata to use as longitude coordinates
%
%   Outputs:
%       models (cell vector [nSite] {scalar PSM object}): The PSM object
%           for each site
%       coordinates (numeric matrix [nSite x 2]): The coordinates of each
%           site. First column is latitude, second is longitude.
%       months (cell vector [nSite] {numeric vector, linear indices}): The
%           indices of the calendar months associated with each site's season

% Get the proxy metadata, and identify the metadata in each column
proxies = gridfile('proxies').metadata;
columns = proxies.attributes.site_metadata_columns;
proxies = proxies.site;

% Locate the columns with the coordinate metadata
latColumn = strcmp(latName, columns);
lonColumn = strcmp(lonName, columns);
assert(sum(latColumn)==1, 'Could not locate the latitude column name in the site metadata');
assert(sum(lonColumn)==1, 'Could not locate the longitude column name in the site metadata');

% Get proxy metadata
ID = proxies(:,1);
type = proxies(:,2);
lat = str2double(proxies(:,latColumn));
lon = str2double(proxies(:,lonColumn));
depth = str2double(proxies(:,9));
cleaning = str2double(proxies(:,10));
species = proxies(:,11);
nSite = numel(ID);

% Validate species strings (see utility function below)
species = validateSpecies(species);

% Locate the different types of records
uk = type=="uk";
tex = type=="tex";
mg = type=="mg";

% Get omega and pH values for Mg/Ca
omega = NaN(nSite, 1);
pH = NaN(nSite, 1);
[omega(mg), pH(mg)] = omgph(lat(mg), lon(mg), depth(mg));

% Create a forward model for each proxy site
models = cell(nSite, 1);
for s = 1:nSite
    if uk(s)
        models{s} = PSM.bayspline;
    elseif tex(s)
        models{s} = PSM.bayspar(lat(s), lon(s));
    elseif mg(s)
        models{s} = PSM.baymag(age, cleaning(s), species(s), 'omega', omega(s), 'pH', pH(s), 'options', {1});
    end     
end

% Optionally determine the seasonal window for the site. Start by
% preallocating seasonal windows
if nargout>1
    months = cell(nSite, 1);
    monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

    % Determine the season for each site
    for s = 1:nSite
        if uk(s)
            months(s) = checkSeasonality(lat(s), lon(s));
        elseif tex(s)
            months(s) = {1:12};
        elseif mg(s)
            [~,~,season] = get_sea(lat(s), lon(s), species(s));
            season = season{1};
            [~, months{s}] = ismember(season, monthNames);
        end
    end
end

% Get the coordinates
coordinates = [lat, lon];

end

%% Utilities
function[species] = validateSpecies(species)

% Locate species indicator strings
sacculifer = contains(species, "sacculifer");
bulloides = contains(species, "bulloides");
sinistral = contains(species, "sinistral");
none = strcmp(species, "");

% Require a single label for everything
nLabel = sacculifer + bulloides + sinistral + none;
missing = nLabel==0;
multiple = nLabel>1;
if any(missing)
    s = find(missing, 1);
    error('Proxy %.f does not have a valid species string', s);
elseif any(multiple)
    s = find(multiple, 1);
    error('Proxy %.f matches multiple species strings', s);
end

% Replace with valid strings
species(sacculifer) = "sacculifer";
species(bulloides) = "bulloides";
species(sinistral) = "incompta";

end