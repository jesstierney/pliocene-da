function[] = runDALocPV(tag, piRuns, plioRuns, LocRadius, networks)

%set tags for timeslices and UK seasonality
timeSliceTags = ["preindustrial"; "mid-pliocene"; "early-pliocene"];
ukSeasonTags = ["uk-med-seasonal_mgcaH";"uk-all-annual_mgcaH";"uk-all-annual_mgcaH"];
Rtag = "conservative";

% default: assimilate all proxies
if ~exist('networks','var') || isempty(networks)
    proxyTypes = gridfile('proxies').metadata.site(:,2);
    allSites = true(size(proxyTypes,1),1);
    networks = allSites;
    networkTags = "all-proxies";
else
    networkTags = "pliovar";
end

%put together ids
reconTags = [repmat(tag,3,1), repmat(networkTags,3,1), ukSeasonTags];
reconLabel = join(reconTags, "_");
estimates = strcat( timeSliceTags, "_", ukSeasonTags);
labels = strcat( timeSliceTags, "_", reconLabel );
ncLabel = strcat(tag,"_Loc",string(LocRadius/1000));

% Assimilate each time slice
assimilateWithLocPV(labels(1), estimates(1), Rtag, LocRadius, piRuns, networks);
assimilateWithLocPV(labels(2), estimates(2), Rtag, LocRadius, plioRuns, networks);
assimilateWithLocPV(labels(3), estimates(3), Rtag, LocRadius, plioRuns, networks);

% Export to NetCDF
exportReconstruction(ncLabel, labels(1), labels(2), labels(3));

end
