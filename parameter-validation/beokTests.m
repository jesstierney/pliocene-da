% Get all runs
piRuns = parameters.preindustrialRuns.all;
plioRuns = parameters.plioceneRuns.all;

% Remove COSMOS
badRuns = parameters.excludeRuns;
remove = ismember(piRuns, badRuns, 'rows');
piRuns(remove,:) = [];
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Calculate dGMST values for runs with altered cloud physics
cloudRuns = [parameters.plioceneRuns.Erfani2019;
             parameters.plioceneRuns.Burls2014];
piBackground = ["CESM1.2.2", "cheyctrl"];
season = parameters.dGMST.season;
deltas = dGMST(piBackground, cloudRuns, season);

% Removes runs outside of acceptable limits
limits = parameters.dGMST.limits;
badDeltas = deltas<limits(1) | deltas>limits(2);
badRuns = cloudRuns(badDeltas, :);
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Parameter tests
scaling = 0.05:0.05:1;
radii = [12000:3000:36000, Inf];

testParameters("preindustrial_beok",  scaling, radii, "preindustrial_uk-med-seasonal",  'conservative', piRuns);
testParameters('mid-pliocene_beok',   scaling, radii, "mid-pliocene_uk-med-seasonal",   'conservative', plioRuns);
testParameters('early-pliocene_beok', scaling, radii, "early-pliocene_uk-med-seasonal", 'conservative', plioRuns);
