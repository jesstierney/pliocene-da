% Get PlioMIP2 runs
piRuns = parameters.preindustrialRuns.pliomip2;
plioRuns = parameters.plioceneRuns.pliomip2;
            %parameters.plioceneRuns.Feng2022];

% Remove COSMOS
badRuns = parameters.excludeRuns;
remove = ismember(piRuns, badRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Parameter tests
scaling = 0.2:0.2:1.2;
radii = [3000:6000:30000, Inf];

testParameters("preindustrial_pliomip",  scaling, radii, "preindustrial_uk-med-seasonal_mgcaH",  'conservative', piRuns);
testParameters('mid-pliocene_pliomip',   scaling, radii, "mid-pliocene_uk-all-annual_mgcaH",   'conservative', plioRuns);
testParameters('early-pliocene_pliomip', scaling, radii, "early-pliocene_uk-all-annual_mgcaH", 'conservative', plioRuns);


