# Proxy record data
This file contains information about the raw proxy record dataset.

## File organization

Each folder contains proxy data for Mg/Ca (mg), UK37 (uk), and TEX86 (tex) respectively. Data are organized into one .csv file per site and have similar columns except for TEX86 which has some special data quality columns (see note below).

## Units & Coordinates
-Age is given in Ma (millons of years before present)
-MBSF, MCD, and WaterDepth are in meters
-Lat and Lon are the modern coordinates in decimal degrees.
-pLat325 and pLon325 are the paleo coordinates for 3.25 Ma and should be used for the mid-Pliocene data assimilation
-pLat475 and pLon475 are the paleo coordinates for 4.75 Ma and should be used for the early Pliocene data assimilation.

## First entry
-The first row after the header row in each file is a preindustrial proxy value
-This comes from either nearby coretops from a coretop database or a forward-modeled value from HadiSST.
-Forward modeled values are means from 1870-1900 and correspond to present day proxy seasonality:

i.e. for BAYSPLINE:

NORTH ATLANTIC (above 48˚N): August-September-October

NORTH PACIFIC (above 45˚N): June-July-August

MEDITERRANEAN & BLACK SEA: November-May

-Lat and Lon coordinates are either the average of the coretops' location or the HadiSST grid cell. these locations should be used for the preindustrial data assimilation.
-Source publication is either HadiSST or the associated coretop database
-Age is always given as 0 for this entry

## Concerning TEX86
TEX86 data have a QualityFlag column identifying datapoints with potential non-thermal influences. Data with a flag == 1 should be excluded. These are based off of recommendations in the source publication as well expert assessment (decisions are being documented in Site Summary table).

## Target time intervals for the Pliocene period

mid-Pliocene data assimilation: use the average of all data between 3-3.5 Ma (we might want to round ages to the nearest 0.1 Ma to facilitate data inclusion).

early Pliocene data assimilation: use the average of all data between 4.5-5.5 Ma (ditto on rounding to 0.1)

preindustrial data assimilation is time 0 and should use the first row of data after the header row as described above.

## Options for R (proxy error variance)

1. Rg (global R, conservative): uk = 0.0025, mg = 0.0169, tex = 0.0025
2. Osman scaling: Take Rg and divide by 3.13, 2.86, and 1.36 for uk, mg, tex respectively.

## Versions of the PSMs to use:

for uk (BAYSPLINE): uk_forward, but input SSTs should be SEASONAL if they are in the modern seasonal polygons. In the latest release of BAYSPLINE there is a function, checkSeasonality, that can spit out which months you need based on the lat/lon.

for tex (BAYSPAR): tex_forward, with options 'SST' and "standard". tolerance "t" is not required for standard mode. You'll need to input lat/lon for this PSM; use modern for the PI step and paleocoords for the Pliocene steps.

for mg (BAYMAG): baymag_forward_ln, which predicts ln(mg/ca) values. BE SURE TO TRANSFORM THE PROXY DATA ln(mg) before calculating the innovation in the DA (!!). Use the species-specific models according to the species listed in the data files. Note that one file has the species, N. atlantica. For this species you can use the "incompta" option. Input SST (t) and SSS (salinity) should be seasonal values per the foram seasonality calculation (use the get_sea.m function in BAYMAG to find what months to grab). Use omgph.m in BAYMAG to get values for omega and pH based on modern (PI) or paleo (Pliocene steps) lat/lon.
