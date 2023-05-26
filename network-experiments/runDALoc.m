function[] = runDALoc(tag, piRuns, plioRuns, LocRadius)

%set tags
timeSliceTags = ["preindustrial"; "mid-pliocene"; "early-pliocene"];
ukSeasonTags = ["uk-med-seasonal";"uk-med-annual";"uk-med-annual"];
Rtag = "conservative";

% Either assimilate all proxies or UK-only
proxyTypes = gridfile('proxies').metadata.site(:,2);
ukSites = proxyTypes=="uk";
allSites = true(size(ukSites));

networks = allSites;
networkTags = "all-proxies";
%put together ids
reconTags = [repmat(tag,3,1), repmat(networkTags,3,1), ukSeasonTags];
reconLabel = join(reconTags, "_");
estimates = strcat( timeSliceTags, "_", ukSeasonTags);
labels = strcat( timeSliceTags, "_", reconLabel );

% Assimilate each time slice
assimilateWithLoc(labels(1), estimates(1), Rtag, LocRadius, piRuns, networks);
assimilateWithLoc(labels(2), estimates(2), Rtag, LocRadius, plioRuns, networks);
assimilateWithLoc(labels(3), estimates(3), Rtag, LocRadius, plioRuns, networks);

% Export to NetCDF
exportReconstruction(reconLabel(1), labels(1), labels(2), labels(3));

end
