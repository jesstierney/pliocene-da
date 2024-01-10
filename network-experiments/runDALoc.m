function[] = runDALoc(tag, piRuns, plioRuns, LocRadius, networks)

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
    sites = gridfile('proxies').metadata.site(:,1);
    sitesLabel = sites(~networks);
    networkTags = strcat("no-",strjoin(sitesLabel,'-')); %else label which sites are left out
end

%put together ids
reconTags = [repmat(tag,3,1), repmat(networkTags,3,1), ukSeasonTags];
reconLabel = join(reconTags, "_");
estimates = strcat( timeSliceTags, "_", ukSeasonTags);
labels = strcat( timeSliceTags, "_", reconLabel );
ncLabel = strcat(tag,"_Loc",string(LocRadius/1000));%,"_",networkTags);

% Assimilate each time slice
assimilateWithLocDevOut(labels(1), estimates(1), Rtag, LocRadius, piRuns, networks);
assimilateWithLocDevOut(labels(2), estimates(2), Rtag, LocRadius, plioRuns, networks);
assimilateWithLocDevOut(labels(3), estimates(3), Rtag, LocRadius, plioRuns, networks);

% Export to NetCDF
%exportReconstruction(ncLabel, labels(1), labels(2), labels(3));

end
