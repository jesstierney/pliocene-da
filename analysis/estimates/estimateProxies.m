function[] = estimateProxies(label, age, ensembleName, latName, lonName)

% Get the proxy metadata, and identify the metadata in each column
proxies = gridfile('proxies').metadata;
columns = proxies.attributes.site_metadata_columns;
proxies = proxies.site;

% Locate the columns with the coordinate metadata
latColumn = strcmp(latName, columns);
lonColumn = strcmp(lonName, columns);

% Get proxy metadata
ID = proxies(:,1);
type = proxies(:,2);
lat = str2double(proxies(:,latColumn));
lon = str2double(proxies(:,lonColumn));
depth = str2double(proxies(:,9));
cleaning = str2double(proxies(:,10));
species = proxies(:,11);
nSite = numel(ID);

% Validate species strings
species = validateSpecies(species);

% Locate the different types of records
uk = type=="uk";
tex = type=="tex";
mg = type=="mg";

% Get the seasonal window for each proxy
months = cell(nSite, 1);
monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
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

% Get omega and pH values for Mg/Ca
omega = NaN(nSite, 1);
pH = NaN(nSite, 1);
[omega(mg), pH(mg)] = omgph(lat(mg), lon(mg), depth(mg));

% Get the ensemble and preallocate metadata.
ens = ensemble(ensembleName);
Ye = NaN(nSite, ens.nMembers);

% Load the monthly TOS and SOS variables. Locate NaN values
tos = ens.useVariables("tos_monthly");
[tos, tosMeta] = tos.load;
tosNAN = isnan(tos);

sos = ens.useVariables("sos_monthly");
[sos, sosMeta] = sos.load;
sosNAN = isnan(sos);

% Create a progress bar. Set it to delete when this function exits
message = sprintf('Estimating %s proxies', label);
h = waitbar(0, message);
deleteBar = onCleanup( @()delete(h) );

% Create a forward model for each proxy site
for s = 1:nSite
    if uk(s)
        model = PSM.bayspline;
    elseif tex(s)
        model = PSM.bayspar(lat(s), lon(s));
    elseif mg(s)
        model = PSM.baymag(age, cleaning(s), species(s), 'omega', omega(s), 'pH', pH(s));
    end    

    % Get seasonal TOS for each site. Also get SOS for Mg/Ca
    coordinates = [lat(s), lon(s)];
    siteTOS = getSiteVariable(tos, tosMeta, tosNAN, coordinates, months{s});
    if mg(s)
        siteSOS = getSiteVariable(sos, sosMeta, sosNAN, coordinates, months{s});
    end

    % Run model using appropriate inputs
    if mg(s)
        X = [siteTOS; siteSOS];
    else
        X = siteTOS;
    end
    Ye(s,:) = model.estimate(X);
    
    % Update progress
    waitbar(s/nSite, h);
end

% Export to NetCDF
[nSite,nMembers] = size(Ye);
nSiteCols = numel(columns);
nMemberCols = 2;

file = strcat(label, "-estimates.nc");
nccreate(file, 'sites_columns', 'Dimensions', {'sites_columns', nSiteCols}, 'Format', 'netcdf4', 'Datatype', 'string');
nccreate(file, 'members_columns', 'Dimensions', {'members_columns',nMemberCols}, 'Datatype', 'string');
nccreate(file, 'sites', 'Dimensions', {'sites',nSite,'sites_columns',nSiteCols}, 'Datatype', 'string');
nccreate(file, 'members', 'Dimensions', {'members',nMembers, 'members_columns',nMemberCols}, 'Datatype', 'string');
nccreate(file, 'Ye', 'Dimensions', {'sites',nSite,'members',nMembers}, 'Datatype', 'double');
nccreate(file, 'ensemble_name', 'datatype', 'string');

ncwriteatt(file, 'sites_columns', 'Description', 'The type of metadata stored along each column of site');
ncwriteatt(file, 'members_columns', 'Description', 'The type of metadata stored along each column of members');
ncwriteatt(file, 'sites', 'Description', 'The proxy sites (and associated metadata)');
ncwriteatt(file, 'members', 'Description', 'The ensemble members');
ncwriteatt(file, 'Ye', 'Description', 'Proxy Estimates');
ncwriteatt(file, 'ensemble_name', 'Description', 'The name of the ensemble used to generate the estimates');

ncwrite(file, 'sites_columns', columns');
ncwrite(file, 'members_columns', ["Model","Experiment"]);
ncwrite(file, 'sites', proxies);
ncwrite(file, 'members', tosMeta.members("run"));
ncwrite(file, 'Ye', Ye);
ncwrite(file, 'ensemble_name', ensembleName);

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
function[Y] = getSiteVariable(X, Xmeta, Xnan, coordinates, months)

% Preallocate
nMembers = Xmeta.nMembers;
Y = NaN(12, nMembers);

% Get the 12 monthly values for each ensemble member
% (different experiments may use different spatial grids, so need to search
% each ensemble member individually to avoid NaNs)
variable = Xmeta.variables;
for m = 1:nMembers
    rows = Xmeta.closestLatLon(variable, coordinates, 'exclude', Xnan(:,m));
    Y(:,m) = X(rows, m);
end

% Get the seasonal mean
Y = Y(months, :);
Y = mean(Y, 1);

end