# pliocene-da
Code to implement paleoclimate data assimilation for the Pliocene and produce the PlioDA. Results are described in the following paper:

Tierney, J.E.,  King, J., Osman, M.B., Abell, J.T., Burls, N.J., Erfani, E., Cooper, V.T., and Feng, R. (2025) Pliocene warmth and patterns of climate change inferred from paleoclimate data assimilation. *AGU Advances*, in press.

## Contents
This repository contains code and small data files (proxy data) required to implement the Pliocene DA reconstruction. Larger required data files (climate model output) can be found on [Zenodo] (https://zenodo.org/doi/10.5281/zenodo.11646735)
The contents of the repository are as follows:

* [HowToRunAnalysis.m](#HowToRunAnalysism)
* [+parameters](#parameters)
* [input_data](#input_data)
* [gridfiles](#gridfiles)
* [ensembles](#ensembles)
* [estimates](#estimates)
* [R-error-variances](#r-error-variances)
* [assimilate](#assimilate)
* [reconstructions](#reconstructions)
* [dGMST.m](#dgmstm)
* [da-experiments](#da-experiments)
* [parameter-validation](#parameter-validation)

Details on each item are provided below. Many of these items are folders containing Matlab functions. You can use the Matlab `help` command to see the documentation of these functions. Additionally, any folders that begin with a plus `+` symbol are Matlab packages. You can read about the contents of these packages using the `help` command, or by reading the package's `Contents.m` page.

### HowToRunAnalysis.m
This function describes how to recreate the reconstruction step-by-step. The function relies on a number of other Matlab functions located in the folders of this repository. You can find instructions for using these functions within this file, and each function also has detailed documentation accessible via the `help` command.

Before running this script, you should first:

1. Install the `DASH` matlab toolbox from [here] (https://github.com/JonKing93/DASH)
2. Download the NetCDF files containing pre-processed climate model output from [Zenodo] (https://zenodo.org/doi/10.5281/zenodo.11646735)
3. Place the pre-processed climate model output in the folder `input_data/model_output/preprocessed/`.
4. Add the `pliocene-da` repository, and all its subfolders, to the active Matlab path.
5. Move the current Matlab directory to the root folder of the `pliocene-da` repository.

You should then be able to run the DA analysis.

### +parameters
This folder is a Matlab package that contains experimental parameters. These include:

* The spatial points used when regridding climate model output,
* The climate model runs used for various ensembles, and
* Global, conservative R values
* parameters for the function dGMST.

### input_data
This folder contains the proxy records and climate model outputs used as input to the assimilation. These are stored in the `model_output` and `proxy_records` subfolders. Each subfolder includes a `Contents.md` file, which are markdown (plain-text) files with details about the associated dataset: [proxy_record Contents](./input_data/proxy_records/Contents.md), [model_output Contents](./input_data/model_output/Contents.md).

We have pre-processed both data sets in preparation for DA. The main pre-processing step for the proxy records is averaging them within various time slices. For the climate model outputs, we have regridded variables to a 1x1 degree curvilinear spatial grid, and computed 100-year monthly climatologies. The pre-processed proxy records are stored in the NetCDF file `proxies.nc` and `proxiesPlioVar.nc` and the pre-processed climate model outputs are stored in a number of NetCDF files in `input_data/model_output/preprocessed`.

In addition to the pre-processed input datasets, each folder also contains the tools needed to rebuild the pre-processed datasets from the raw data source files.

----

In `proxy_records`, you will find:

* A folder named `raw`: This contains the raw proxy data records, prior to any pre-processing. See its [Contents file](./input_data/proxy_records/raw/Contents.md) for information about the raw files.

* The Matlab class `proxyData.m`: This class contains all the code used to pre-process the proxy records. See `help proxyData.organize` for details.

* The NetCDF file `proxies.nc`: This is the pre-processed proxy record dataset used as input to the assimilation.

* The NetCDF file `proxiesPlioVar.nc`: This is the pre-processed proxy record dataset that meet the PlioVar criteria for being representative of the KM5c interglacial, used as input for the PlioVar data assimilation experiment.

----

In `model_output`, you will find:

* A [Contents.md](./input_data/model_output/Contents.md) file: This contains information about the climate model datasets used in the assimilation.

* A `raw` folder: This folder includes summaries of the raw climate model output files used for pre-processing. It also includes all the code necessary to re-process the files. See its [Contents.md file](./input_data/model_output/raw/Contents.md) for details.

* A `preprocessed` folder: This folder holds the pre-processed climate model NetCDF files used as input to the assimilation. You will need to download these from Zenodo and then put those files here.


### gridfiles
This folder holds the functions `buildProxyGridfile` and `buildModelGridfiles`, which are used to build the gridfiles for the proxies and climate model data. The folder may also hold the `.grid` files once you create them.

### ensembles
This folder holds the function `buildEnsemble`. This function builds state vector ensembles for the assimilation. The function allows you to build ensembles from different sets of climate model runs. The folder may also hold `.ens` files once you build them.

### estimates
This folder holds the proxy estimates (Ye) and associated functions.

* `estimateProxies`: This function allows you to estimate proxy records for given time slice, ensemble, and set of (paleo)coordinates.
* `buildPSMs`: This is a utility function that builds the PSMs used to estimate proxies. It is called by `estimateProxies`, but you do not need to call this function directly.
* Pre-computed proxy estimates, stored as NetCDF `.nc` files. There are three different versions for each timeslice: 1) `all-annual` in which the proxy estimates are modeled assuming that alkenone U<sup>K'</sup><sub>37</sub> represents annual mean SST everywhere, 2) `all_annual` with `mgDynamic`, which is the same as 1) but with Mg/Ca data modeled with varying seasonality between the timeslices, 3) `med-seasonal` in which the proxy estimates are modeled assuming seasonal U<sup>K'</sup><sub>37</sub> signatures in the Mediterranean, North Pacific, and North Atlantic, in accordance with the assumption in the BAYSPLINE model.

### R-error-variances
This folder holds the function `calculateR`. This function computes R values (error-variances) for the proxy records using global, conservative R values.

The folder also holds the NetCDF files `R-conservative.nc` which contains pre-computed R variances for the proxy records.

### assimilate
This folder holds functions to conduct the data assimilation. These functions use the DASH toolbox to implement a Kalman Filter for a time step of the reconstruction. The basic function `assimilate` allows you to specify the time slice, ensemble/set of estimates, R values, and climate model runs to use as ensemble members. `assimilateWithLoc` is a variation of `assimilate` that includes covariance localization. `assimilateWithLocDevOut` allows you to save the deviations in addition to the posterior ensemble mean. `assimilateWithLocPV` and `assimilateWithLocDevOutPV` are for use with the PlioVar DA experiment.

The folder also holds the functions `loadCoreInputs` and `loadCoreInputsPV`. These are utility functions used by the `assimilate` functions and you do not need to call them directly.

The folder may also hold `.mat` files containing Kalman filter outputs from DASH, once you generate them.

### reconstructions
This folder holds the functions `exportReconstruction` and `exportReconstructionPlioVar`, for the main and PlioVar DA experiments respectively. These functions exports assimilation outputs from the DASH toolbox to NetCDF. It regrids assimilated state vector variables back onto spatial grids, and combines outputs from preindustrial, mid-Pliocene, and early-Pliocene time slices. The folder may also hold NetCDF `.nc` files with reconstruction output, once you generate them.

### dGMST.m
This function allows you to calculate delta GMST between two pre-processed climate model runs. GMST is computed from the tas (near surface air temperature) field using a latitude-weighted spatial mean.

### da-experiments
This folder holds functions that produce the DA reconstructions presented in the paper using different experimental configurations. The contents include:

* `pliomip.m`: Runs experiments using only PlioMIP2 runs, excluding COSMOS and all cloud physics runs
* `pliomipCloud.m`: Runs experiments using the full prior, which includes PlioMIP2 runs (excluding COSMOS) and cloud runs (excluding those with unrealistic dGMST, i.e. outside of 1 and 8 degrees difference from preindustrial).
* `pliomipCloudPlioVar`: Runs an experiment using the full prior as above, but only assimilates proxy data that meet PlioVar criteria for representing the KM5c interglacial.
* `cesmCloud.m`: Runs experiments using all CESM-family (CCSM and CESM) runs for the PI timeslice, and then only the perturbed cloud runs for the Pliocene slices (excluding unrealistic dGMST as above).

To use these functions, you should enter `pliomip` etc in the MATLAB console. Note that you must first generate the ensembles, estimates, and R error variances detailed in [HowToRunAnalysis.m](#HowToRunAnalysism) before you will be able to use these functions.

* This folder also contains the functions `runDAnoLoc`, `runDALoc`, `runDALocDev` which are called in the `pliomip`, etc. functions and correspond to whether you want to localize or not, or output deviations or not. `runDALocPV` and `runDALocDevPV` are designed for the use with the PlioVar DA experiment.

### parameter-validation
This folder holds functions that performs a series of single-proxy knockout validation experiments for a set of R scalings and localization radii in a particular time slice. Proxy validation values are exported to a NetCDF file. The folder may also hold NetCDF `.nc` files with the output of these tests.
