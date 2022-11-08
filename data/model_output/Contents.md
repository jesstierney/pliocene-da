# Climate model output data
This folder contains two folders

* [preprocessed](#preprocessed), and
* [raw](#raw)

which organize the climate model output data used for the assimilation. The institutions associated with the various climate model runs are also [summarized below](#modeling-institutions).


## Preprocessed
This folder contains the pre-processed climate model output data used for assimilation. The folder contains a number of NetCDF files. Each NetCDF file data values for a particular model run. The naming convention is `<model name>_<experiment ID>.nc` (and the experiment IDs are [summarized below](#experiment-ids)).

Each file holds data for the following variables:

| Variable | Description | Units |
| -------- | ----------- | ----- |
| pr | Total precipitation | mm / day |
| tas | Near-Surface air temperature | Kelvin |
| tos | Sea surface temperature | Celsius |
| sos | Sea surface salinity | g/kg  (equivalent to psu) |
| siconc | Sea ice area fraction | Percentage (on interval from 0 to 100) |

(Note that we follow CMIP6 naming conventions when naming variables).

The data for each variable consists of 12 monthly climatologies. Each climatology is constructed using a 100-year average. All variables have been regridded to a 1 degree x 1 degree curvilinear spatial grid.

Currently, the pre-processed climate output is stored in the following Google Drive Folder: [Pre-processed NetCDFs](https://drive.google.com/drive/folders/18J7O8Ahz30bfhab11OFJltG7vT_1rYP8?usp=sharing)


### Experiment IDs
The following table summarizes the experiment IDs in the climate model output dataset:

| Experiment | Description | Citation |
| ---------- | ----------- | -------- |
| E280       | A run with pre-industrial (1850 CE) boundary conditions | [Haywood et al., (2020)](https://doi.org/10.5194/cp-2019-145) |
| Eoi400     | A run with mid-Pliocene boundary conditions | [Haywood et al., (2020)](https://doi.org/10.5194/cp-2019-145) |
| pi.400     | (CESM2) A run with pre-industrial boundary conditions and 400 ppm CO2 | [Feng et al., (2022)](https://doi.org/10.1038/s41467-022-28814-7) |
| eo400.new  | (CESM2) Pliocene topography, geography and CO2 (400 ppm), but preindustrial vegetation and ice sheet | [Feng et al., (2022)](https://doi.org/10.1038/s41467-022-28814-7) |
| PreInd     | (CESM1.2.2) A pre-industrial control run | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |
| PlioB17    | (CESM1.2.2) A run with early-Pliocene boundary conditions | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |
| Plio       | (CESM1.2.2) A run with mid-Pliocene boundary conditions | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |



## Raw
This folder contains 

* summaries of the raw data files used to construct the pre-processed dataset, and
* The Matlab scripts used to pre-process the output

You can read in detail about the `raw` folder in its [Contents.md](./raw/Contents.md) file.


## Modeling Institutions
The following table summaries the modeling institution associated with each climate model.

| Model        | Institution |
| -----        | ----------- |
| CCSM4-UoT    | University of Toronto, Canada |
| CESM1.0.5    | IMAU, Utrecht University, Netherlands |
| CESM1.2.2    | National Center for Atmospheric Research (NCAR) |
| CESM2        | National Center for Atmospheric Research (NCAR) |
| COSMOS       | Alfred Wegener Institute (AWI), Germany |
| EC-Earth3.3  | Stockholm University, Sweden |
| GISS-ModelE2 | NASA Goddard Institute for Space Studies |
| HadCM3       | University of Leeds, United Kingdom |
| HadGM3       | University of Leeds, United Kingdom |
| IPSL-CM5A    | Laboratory for Sciences of Climate and Environment, France |
| IPSL-CM5A2   | Laboratory for Sciences of Climate and Environment, France |
| IPSL-CM6A    | Laboratory for Sciences of Climate and Environment, France |
| MIROC4m      | Center for Climate System Research, University of Tokyo & National Inst. For Env. Studies, Japan |
| NorESM1-F    | Norwegian Research Center, Bjerknes Centre for Climate Research, Bergen, Norway |
| NorESM-L     | Norwegian Research Center, Bjerknes Centre for Climate Research, Bergen, Norway |
