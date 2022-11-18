function[] = plotVariable(file, variable, seasonMonths)

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

% Permute to lat x lon
X = X';

% Plot
figure;
m_proj('miller', 'lat', [-90 90], 'lon', [0 360]);
m_pcolor(lon, lat, X);
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

