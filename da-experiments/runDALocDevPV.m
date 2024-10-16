function[] = runDALocDevPV(tag, piRuns, plioRuns, LocRadius, networks)

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

% Assimilate each time slice and save deviations
assimilateWithLocDevOutPV(labels(1), estimates(1), Rtag, LocRadius, piRuns, networks);
assimilateWithLocDevOutPV(labels(2), estimates(2), Rtag, LocRadius, plioRuns, networks);
assimilateWithLocDevOutPV(labels(3), estimates(3), Rtag, LocRadius, plioRuns, networks);

end