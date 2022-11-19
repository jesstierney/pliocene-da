function[] = exportReconstruction(label, piFile, midPlioFile, earlyPlioFile)

% Get full file names
piFile = strcat(piFile, '-assimilation.mat');
midPlioFile = strcat(midPlioFile, '-assimilation.mat');
earlyPlioFile = strcat(earlyPlioFile, '-assimilation.mat');

% Get a matfile object for each file
pi = matfile(piFile);
midPlio = matfile(midPlioFile);
earlyPlio = matfile(earlyPlioFile);

% Get the ensemble metadata object and the reconstruction targets
ensMeta = pi.ensMeta;
variables = ensMeta.variables;

% Get sizes
[X, Xmeta] = ensMeta.regrid(variables(1), pi.Amean);
[nLon, nLat] = size(X);
lon = Xmeta.lon;
lat = Xmeta.lat;

% Create NetCDF variables
nTime = 3;
file = strcat(label, '.nc');
nccreate(file, 'lon', 'Dimensions', {'lon',nLon});
nccreate(file, 'lat', 'Dimensions', {'lat',nLat});
nccreate(file, 'time', 'Dimensions', {'time', nTime});
for v = 1:numel(variables)
    nccreate(file, variables(v), 'Dimensions', {'lon',nLon,'lat',nLat,'time',nTime});
end

% Write dimension attributes
ncwriteatt(file, 'lon', 'Units', 'Decimal degrees east')
ncwriteatt(file, 'lon', 'Range', '0-360');
ncwriteatt(file, 'lat', 'Units', 'Decimal degrees north');
ncwriteatt(file, 'time', 'Units', 'Ma');

% Get the variable name and season of each reconstruction target
for v = 1:numel(variables)
    varSeason = split(variables(v), '_');
    assert(numel(varSeason)==2, 'Variable name could not be split into variable and season: %s', variables(v));
    var = varSeason(1);
    season = varSeason(2);
    assert(ismember(var, ["pr","tas","tos","sos","siconc"]), 'Unrecognized variable: %s', var);
    assert(ismember(season, ["annual","DJF","JJA"]), 'Unrecognized season: %s', season);

    % Get a string to identify the season
    if season=="annual"
        season = "Annual";
    elseif season=="DJF"
        season = "Winter (DJF)";
    elseif season=="JJA"
        season = "Summer (JJA)";
    end

    % Get an ID string and units for the variable
    if var=="pr"
        var = "precipitation (total)";
        units = "mm/day";
    elseif var=="tas"
        var = "near surface (usually 2m) air temperature";
        units = "Kelvin";
    elseif var=="tos"
        var = "sea surface temperature";
        units = "Celsius";
    elseif var=="sos"
        var = "sea surface salinity";
        units = "psu";
    elseif var=="siconc"
        var = "sea ice area percentage";
        units = "%";
    end

    % Write variable attributes
    description = strcat(season, " ", var);
    ncwriteatt(file, variables(v), 'Description', description);
    ncwriteatt(file, variables(v), 'Units', units);
end

% Write dimensions
time = [pi.age; midPlio.age; earlyPlio.age];
ncwrite(file, 'lon', lon);
ncwrite(file, 'lat', lat);
ncwrite(file, 'time', time);

% Write variables
for v = 1:numel(variables)
    Xpi = ensMeta.regrid(variables(v), pi.Amean);
    Xmid = ensMeta.regrid(variables(v), midPlio.Amean);
    Xearly = ensMeta.regrid(variables(v), earlyPlio.Amean);
    X = cat(3, Xpi, Xmid, Xearly);
    
    ncwrite(file, variables(v), X);
end

end