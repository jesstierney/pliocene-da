function[delta] = dGMST(piFile, plioFile, seasonMonths)
%% dGMST  Computes delta GMST for pre-processed climate model output
% ----------
%   delta = dGMST(piFile, plioFile, seasonMonths)
%   Computes delta GMST between two pre-processed climate model output
%   files. GMST is calculated using a latitude-weighted, global mean over 
%   the tas (near surface air temperature) field. Calculates GMST over a
%   specified seasonal mean.
% ----------
%   Inputs:
%       piFile (string scalar): The name of a file holding a pre-processed
%           output from a preindustrial run
%       plioFile (string scalar): The name of a file holding pre-processed
%           output from a pliocene run
%       seasonMonths (numeric vector): Indicates the months to use for a
%           seasonal mean.Elements should be integers on the
%            interval 1:12. For example, use 1:12 for an annual mean,
%            [12 1 2] for DJF, and [6 7 8] for JJA.
%
%   Outputs:
%       delta (numeric scalar): Delta GMST between the two runs

% Get GMST values
Tpi = gmst(piFile, seasonMonths);
Tplio = gmst(plioFile, seasonMonths);

% Get the difference
delta = Tplio - Tpi;

end

%% Utility
function[T] = gmst(file, seasonMonths)

% Load the variable
if ~endsWith(file, '.nc')
    file = strcat(file, '.nc');
end
T = ncread(file, 'tas');

% Get the requested seasonal mean
T = T(:,:,seasonMonths);
T = mean(T, 3);

% Take longitude mean and note NaN points
T = mean(T,1,'omitnan');
nans = isnan(T);

% Take latitude-weighted spatial mean
lat = ncread(file, 'lat');
latWeights = cosd(lat');
latWeights(nans) = NaN;
T = sum(latWeights.*T,'omitnan') / sum(latWeights,'omitnan');

end