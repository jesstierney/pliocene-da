function[] = plotVariable(file, variable, seasonMonths)
%% plotVariable  Plots a pre-processed climate model variable for a seasonal mean
% ----------
%    plotVariable(file, variable, seasonMonths)
%    Given a NetCDF file holding pre-processed climate model output, plots
%    a variable from the file over a requested seasonal mean. Uses the
%    m_map package with a miller projection to display global climate
%    variable fields. Uses a -180 to 180 coordinate system to facilitate
%    checking for clipped longitudes.
% ----------
%    Inputs:
%        file (string scalar): The name of a file holding pre-processed
%            climate model output. If the file does not have a ".nc"
%            extension, the method adds one automatically.
%        variable (string scalar): The name of a climate variable in the
%            file. Options are "pr", "tas", "tos", "sos", and "siconc"
%        seasonMonths (numeric vector): Indicates the months to use in the
%            plotted seasonal mean. Elements should be integers on the
%            interval 1:12. For example, use 1:12 for an annual mean,
%            [12 1 2] for DJF, and [6 7 8] for JJA.
%
%    Outputs:
%        Creates a new figure that maps the pre-processed variable over the
%        requested season.

% Load the variable
if ~endsWith(file, '.nc')
    file = strcat(file, '.nc');
end
X = ncread(file, variable);
            
% Get the requested seasonal mean
X = X(:,:,seasonMonths);
X = mean(X, 3);

% Load the coordinates
lat = ncread(file, 'lat');
lon = ncread(file, 'lon');

% Convert to -180 to 180 coordinate system to facilitate checking for
% longitude clipping
[X, lon] = regrid.longitude(180, lon, X);

% Plot
figure;
m_proj('miller', 'lat', [-90 90], 'lon', [-180 180]);
m_pcolor(lon, lat, X');
m_coast;
m_grid;

% Use diverging colormap
cmap = cbrew('redblue', 100, true);
scaleColorMap(cmap, 0);

% Label
run = char(file);
run = run(1:end-3);
titleStr = sprintf('%s: %s', run, variable);
title(titleStr, 'Interpreter', 'none');

end

