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
cloudRuns1 = parameters.plioceneRuns.Erfani2019;
cloudRuns2 = parameters.plioceneRuns.Burls2014;
piBackground1 = ["CESM1.2.2", "cheyctrl"];
piBackground2 = ["CESM1.0.4", "piControl"];
season = parameters.dGMST.season;
deltas1 = dGMST(piBackground1, cloudRuns1, season);
deltas2 = dGMST(piBackground2, cloudRuns2, season);

% Removes runs outside of acceptable limits
limits = parameters.dGMST.limits;
badDeltas1 = deltas1<limits(1) | deltas1>limits(2);
badDeltas2 = deltas2<limits(1) | deltas2>limits(2);
badRuns = [cloudRuns1(badDeltas1, :); cloudRuns2(badDeltas2, :)];
remove = ismember(plioRuns, badRuns, 'rows');
plioRuns(remove,:) = [];

% Parameter tests
scaling = 0.2:0.2:1.2;
radii = [3000:6000:30000, Inf];

testParameters("preindustrial_beok",  scaling, radii, "preindustrial_uk-med-seasonal_mgcaH",  'conservative', piRuns);
testParameters('mid-pliocene_beok',   scaling, radii, "mid-pliocene_uk-all-annual_mgcaH",   'conservative', plioRuns);
testParameters('early-pliocene_beok', scaling, radii, "early-pliocene_uk-all-annual_mgcaH", 'conservative', plioRuns);
