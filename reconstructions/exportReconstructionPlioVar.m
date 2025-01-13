function[] = exportReconstructionPlioVar(label, piFile, midPlioFile)
%% exportReconstruction  Exports reconstruction outputs to NetCDF
% ----------
%   exportReconstruction(label, piFile, midPlioFile, earlyPlioFile)
%   Exports a reconstruction to NetCDF. Takes saved outputs from DASH
%   Kalman Filters and regrids them to a curvilinear spatial grid. Combines
%   values from preindustrial, mid-pliocene, and early-pliocene
%   assimilations into a single reconstruction.
% ----------
%   Inputs:
%       label (string scalar): A label to use for the reconstruction. The
%           label will be used as the name of the exported NetCDF file.
%       piFile (string scalar): The label for the pre-industrial
%           assimilation. This should be the first part of the saved .mat
%           file (i.e. the file name prior to the "_assimilation.mat")
%       midPlioFile (string scalar): The label for the mid-pliocene assimilation
%       earlyPlioFile (string scalar): The label for the early-Pliocene assimilation
%
%   Outputs:
%       Creates a file named "<label>.nc" in the current directory

% Get full file names
piFile = strcat(piFile, '_assimilation.mat');
midPlioFile = strcat(midPlioFile, '_assimilation.mat');

% Get a matfile object for each file
pi = matfile(piFile);
midPlio = matfile(midPlioFile);

% Get the ensemble metadata object and the reconstruction targets
ensMeta = pi.ensMeta;
variables = ensMeta.variables;

% Get sizes
[X, Xmeta] = ensMeta.regrid(variables(1), pi.Amean);
[nLon, nLat] = size(X);
lon = Xmeta.lon;
lat = Xmeta.lat;

% Create NetCDF variables
nTime = 2;
nMonth = 12;
file = strcat(label, '.nc');
nccreate(file, 'lon', 'Dimensions', {'lon',nLon});
nccreate(file, 'lat', 'Dimensions', {'lat',nLat});
nccreate(file, 'time', 'Dimensions', {'time', nTime});
nccreate(file, 'month', 'Dimensions', {'month', nMonth});
for v = 1:numel(variables)
    if contains(variables(v),"monthly")
        nccreate(file, variables(v), 'Dimensions', {'lon',nLon,'lat',nLat,'month',nMonth,'time',nTime});
    else
        nccreate(file, variables(v), 'Dimensions', {'lon',nLon,'lat',nLat,'time',nTime});
    end
end

% Write dimension attributes
ncwriteatt(file, 'lon', 'Units', 'Decimal degrees east')
ncwriteatt(file, 'lon', 'Range', '0-360');
ncwriteatt(file, 'lat', 'Units', 'Decimal degrees north');
ncwriteatt(file, 'time', 'Units', 'Ma');
ncwriteatt(file, 'month', 'Units', 'Month of year');

% Get the variable name and season of each reconstruction target
for v = 1:numel(variables)
    varSeason = split(variables(v), '_');
    assert(numel(varSeason)==2, 'Variable name could not be split into variable and season: %s', variables(v));
    var = varSeason(1);
    season = varSeason(2);
    assert(ismember(var, ["pr","ev","tas","tos","sos","siconc"]), 'Unrecognized variable: %s', var);
    assert(ismember(season, ["annual","DJF","JJA","monthly"]), 'Unrecognized season: %s', season);

    % Get a string to identify the season
    if season=="annual"
        season = "Annual";
    elseif season=="DJF"
        season = "Winter (DJF)";
    elseif season=="JJA"
        season = "Summer (JJA)";
    elseif season=="monthly"
        season = "Monthly";
    end

    % Get an ID string and units for the variable
    if var=="pr"
        var = "precipitation (total)";
        units = "mm/day";
    elseif var=="ev"
        var = "evaporation";
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
time = [pi.age; midPlio.age];
ncwrite(file, 'lon', lon);
ncwrite(file, 'lat', lat);
ncwrite(file, 'time', time);
ncwrite(file, 'month', 1:12);

% Write variables
for v = 1:numel(variables)
    Xpi = ensMeta.regrid(variables(v), pi.Amean);
    Xmid = ensMeta.regrid(variables(v), midPlio.Amean);
    if contains(variables(v),"monthly")
        X = cat(4, Xpi, Xmid);
    else
        X = cat(3, Xpi, Xmid);
    end    
    ncwrite(file, variables(v), X);
end

end