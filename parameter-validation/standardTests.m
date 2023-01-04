% Get CESM2 and PlioMIP2 runs
piRuns = parameters.preindustrialRuns.pliomip2;
plioRuns = [parameters.plioceneRuns.pliomip2;
            parameters.plioceneRuns.Feng2022];

% Remove COSMOS runs
removeRuns = parameters.excludeRuns;
remove = ismember(piRuns, removeRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, removeRuns, 'rows');
plioRuns(remove,:) = [];

% Parameter tests
scaling = 0.05:0.05:1;
radii = [12000:3000:36000, Inf];

testParameters("preindustrial_standard",  scaling, radii, "preindustrial_uk-med-seasonal",  'conservative', piRuns);
testParameters('mid-pliocene_standard',   scaling, radii, "mid-pliocene_uk-med-seasonal",   'conservative', plioRuns);
testParameters('early-pliocene_standard', scaling, radii, "early-pliocene_uk-med-seasonal", 'conservative', plioRuns);


