%% optimalParameters
%  
% This is a demo script indicating how you might try to select optimal
% parameters from the results of the proxy knockout experiments


% Get the file containing parameter validation results. Also get a label
% for the plot.
file = "preindustrial_standard_parameter-validation.nc";
tag = "Preindustrial, standard";

% Load the proxy observations and the LOO validation values. Also load the
% scaling weights and the localization radii used in the parameter sweep
Y = ncread(file, 'Y');
Ypost = ncread(file, 'Ypost');
scalings = ncread(file, 'scalings');
radii = ncread(file, 'radii');

% Compute relative error
RE = abs(Y-Ypost) ./ Y;

% Use a summary statistic across the proxy network for each parameter
% combination. (Each parameter combination consists of an R scaling weight,
% and a localization radius). Set the color limits for the plot based on
% the type of summary statistic
RE = median(RE, 1, 'omitnan');
RE = squeeze(RE);
clim = [0 1];

% Locate the minimum RE value across the set of parameter combinations
[minRE, optimalIndex] = min(RE, [], 'all');
[s, r] = ind2sub(size(RE), optimalIndex);

% Get the associated scaling weight and localization radius
optimalScaling = scalings(s);
optimalRadius = radii(r);

% Plot
figure
imagesc(RE);

xticks(1:numel(radii));
xticklabels(radii);
xlabel("Localization Radius (km)");

yindex = 2:2:numel(scalings);
yticks(yindex);
yticklabels(scalings(yindex));
ylabel("R scaling");
set(gca,'YDir', 'normal')

cmap = cbrew('wyred', 100);
colormap(cmap);
colorbar;
title(sprintf('Median |RE|: %s', tag));
set(gca, 'clim', clim, 'fontsize', 16);
