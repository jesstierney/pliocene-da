function[] = runDAnoLoc(tag, piRuns, plioRuns)

%set tags
timeSliceTags = ["preindustrial"; "mid-pliocene"; "early-pliocene"];
ukSeasonTags = ["uk-med-seasonal";"uk-med-annual";"uk-med-annual"];
Rtag = "conservative";

% Either assimilate all proxies or UK-only
proxyTypes = gridfile('proxies').metadata.site(:,2);
allSites = true(size(proxyTypes,1),1);

networks = allSites;
networkTags = "all-proxies";
%put together ids
reconTags = [repmat(tag,3,1), repmat(networkTags,3,1), ukSeasonTags];
reconLabel = join(reconTags, "_");
estimates = strcat( timeSliceTags, "_", ukSeasonTags);
labels = strcat( timeSliceTags, "_", reconLabel );
ncLabel = strcat(tag,"_","noLoc");

% Assimilate each time slice
assimilate(labels(1), estimates(1), Rtag, piRuns, networks);
assimilate(labels(2), estimates(2), Rtag, plioRuns, networks);
assimilate(labels(3), estimates(3), Rtag, plioRuns, networks);

% Export to NetCDF
exportReconstruction(ncLabel, labels(1), labels(2), labels(3));

end
