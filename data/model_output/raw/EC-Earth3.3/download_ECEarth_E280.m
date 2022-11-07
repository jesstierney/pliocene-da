function[] = download_ECEarth_E280(variable)
%% download_ECEarth_E280  Downloads raw E280 output for EC-Earth3.3 from ESGF using HTTP
% ----------
%   download_ECEarth_E280(variable)
%   Downloads raw output files for a specified variable in the E280
%   experiment for EC-Earth3.3. Uses a HTTP protocol to download files.
%   
%   This method provides an alternative to using the "wget script" download
%   option. However, the wget option is probably better, so you should only
%   use this script if the wget script is not working.
% ----------
%   Inputs:
%       variable (string scalar): The name of the variable to download.
%           Options are:
%           ["pr"]: Total Precipitation
%           ["tas"]: Near surface air temperature
%           ["tos"]: Sea surface temperature
%           ["sos"]: Sea surface salinity
%           ["siconc"]: Sea ice fraction
%
%   Outputs:
%       Downloads a number of NetCDF files using the default system
%       browser. Files are downloaded to the current directory

%%% Parameters
% The first and last year in the range of downloaded files
startYear = 2219;
 stopYear = 2318;
%%%

% Get the recognized variables and paths
variables = [
    "pr", "http://esg-dn1.nsc.liu.se/thredds/fileServer/esg_dataroot7/cmip6data/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3-LR/piControl/r1i1p1f1/Amon/pr/gr/v20200409/pr_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc"
    "tas", "http://esg-dn1.nsc.liu.se/thredds/fileServer/esg_dataroot7/cmip6data/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3-LR/piControl/r1i1p1f1/Amon/tas/gr/v20200409/tas_Amon_EC-Earth3-LR_piControl_r1i1p1f1_gr_%4.f01-%4.f12.nc"
    "tos", "http://esg-dn1.nsc.liu.se/thredds/fileServer/esg_dataroot7/cmip6data/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3-LR/piControl/r1i1p1f1/Omon/tos/gn/v20200919/tos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc"
    "sos", "http://esg-dn1.nsc.liu.se/thredds/fileServer/esg_dataroot7/cmip6data/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3-LR/piControl/r1i1p1f1/Omon/sos/gn/v20200919/sos_Omon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc"
    "siconc", "http://esg-dn1.nsc.liu.se/thredds/fileServer/esg_dataroot7/cmip6data/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3-LR/piControl/r1i1p1f1/SImon/siconc/gn/v20200919/siconc_SImon_EC-Earth3-LR_piControl_r1i1p1f1_gn_%4.f01-%4.f12.nc"
    ];

% Check the variable is allowed
assert(isstring(variable), 'variable must be a string');
assert(isscalar(variable), 'variable must be scalar');
[ismem, v] = ismember(variable, variables);
assert(ismem, 'variable must be "pr", "tas", "tos", "sos", or "siconc"');

% Get the path to the downloaded file
path = variables(v,2);
for year = startYear:stopYear
    downloadURL = sprintf(path, year, year);
    
    % Download and save the file
    [~, file] = fileparts(downloadURL);
    saveTo = strcat(file, ".nc");
    websave(saveTo, downloadURL);

    % Display progress
    progress = 100 * (year - startYear + 1) / (stopYear-startYear+1);
    fprintf('%.1f%%\n', progress);
end

end