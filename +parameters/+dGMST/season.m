function[season] = season
%% parameters.dGMST.season  Return the season for dGMST values used to screen climate model runs
% ----------
%   season = parameters.dGMST.season
%   Returns the season for which to calculate dGMST values when screening
%   climate model runs from the prior.
% ----------
%   Outputs:
%       season (numeric vector [nMonths]): Indicates the season in which to
%           calculate dGMST. Element are the linear indices of the calendar
%           months in the season of interest. For example, 1:12 for annual,
%           or 6:8 for JJA.

season = 1:12;

end