# pliocene-da
A project to implement paleoclimate data assimilation for the Pliocene.

## Contents
This repository contains code and small data files required to implement the Pliocene DA reconstruction. Larger required data files are located on the project's Google drive: [Google Drive](https://drive.google.com/drive/folders/1pvsxnG-OX3qoHVjYu2p9AKGhyeVtKgsR?usp=sharing)

The contents of the repository are as follows:

* [runAnalysis.m](#runAnalysism)
* [+parameters](#parameters)
* [input_data](#input_data)
* [gridfiles](#gridfiles)
* [ensembles](#ensembles)
* [estimates](#estimates)
* [R-error-variances](#r-error-variances)
* [assimilate](#assimilate)
* [reconstructions](#reconstructions)

and details on each item are provided below. Many of these items are folders containing Matlab functions. You can use the Matlab `help` command to see the documentation of these functions. Additionally, any folders that begin with a plus `+` symbol are Matlab packages. You can read about the contents of these packages using the `help` command, or by reading the package's `Contents.m` page.

### runAnalysis.m
You can use the `runAnalysis` function to recreate the reconstruction. The function relies on a number of other Matlab functions located in the folders of this repository. You can find instructions for using these functions within `runAnalysis.m`, and each function also has detailed documentation accessible via the `help` command.

Before running this script, you should first:

1. Download the NetCDF files containing pre-processed climate model output from the Google drive
2. Place the pre-processed climate model output in the folder `input_data/climate_models/preprocessed/`.
3. Add the `pliocene-da` repository, and all its subfolders, to the active Matlab path.
4. Move the current Matlab directory to the root folder of the `pliocene-da` repository.

You should then be able to run the script. If you re-run this script, it will create all output files in the current directory. Note that we have sorted these output files into various folders for the sake of organization.

### +parameters
This folder is a Matlab package that contains experimental parameters used throughout the experiment. These include:

* The spatial points used when regridding climate model output,
* The climate model runs used for various ensembles, and
* Global, conservative R values and the Osman scaling weights

See `help parameters` or read `+parameters/Contents.m` for details on the package contents. You can edit any of these parameters to alter the parameters of the experiment. For example, you can edit the spatial points to assimilate a different spatial grid. If changing parameters, be sure to re-run the `runAnalysis.m` script.

### input_data
This folder contains the proxy records and climate model outputs used as input to the assimilation. These are stored in the `model_output` and `proxy_records` subfolders. Each subfolder includes a `Contents.md` file, which are markdown (plain-text) files with details about the associated dataset: [proxy_record Contents](./input_data/proxy_records/Contents.md), [model_output Contents](./input_data/model_output/Contents.md).

We have pre-processed both data sets in preparation for DA. The main pre-processing step for the proxy records is averaging them within various time slices. For the climate model outputs, we have regridded variables to a 1x1 degree curvilinear spatial grid, and computed 100-year monthly climatologies. The pre-processed proxy records are stored in the NetCDF file `proxies.nc`, and the pre-processed climate model outputs are stored in a number of NetCDF files in `input_data/model_output/preprocessed`.

In addition to the pre-processed input datasets, each folder also contains the tools needed to rebuild the pre-processed datasets from the raw data source files.

----

In `proxy_records`, you will find:

* A folder named `raw`: This contains the raw proxy data records, prior to any pre-processing. See its [Contents file](./input_data/proxy_records/raw/Contents.md) for information about the raw files.

* The Matlab class `proxyData.m`: This class contains all the code used to pre-process the proxy records. See `help proxyData.organize` for details.

* The NetCDF file `proxies.nc`: This is the pre-processed proxy record dataset used as input to the assimilation.

----

In `model_output`, you will find:

* A [Contents.md](./input_data/model_output/Contents.md) file: This contains information about the climate model datasets used in the assimilation.

* A `raw` folder: This folder includes summaries of the raw climate model output files used for pre-processing. It also includes all the code necessary to re-process the files. See its [Contents.md file](./input_data/model_output/raw/Contents.md) for details.

* A `preprocessed` folder: This folder holds the pre-processed climate model NetCDF files used as input to the assimilation


### gridfiles
This folder holds the functions `buildProxyGridfile` and `buildModelGridfiles`, which are used to build the gridfile catalogues for the proxy record and climate model output datasets. The folder may also hold `.grid` files, which are pre-built gridfiles for the analysis.

### ensembles
This folder holds the function `buildEnsemble`. This function builds state vector ensembles for assimilation. The function allows you to build ensembles from different sets of climate model runs. The folder may also hold `.ens` files, which are pre-built state vector ensembles for the analysis.

### estimates
This folder holds the function `estimateProxies`. This function allows you to estimate proxy records for given time slice, ensemble, and set of paleo(coordinates). The folder may also hold pre-computed proxy estimates, stored in various NetCDF `.nc` files.

### R-error-variances
This folder holds the function `calculateR`. This function computes R values (error-variances) for the proxy records using:

1. global, conservative R values, and
2. The Osman scaling

The folder may also hold the NetCDF files `R-conservative.nc` and `R-osman.nc`, which hold pre-computed R variances for the proxy records.

### assimilate
This folder holds the function `assimilate`. This function uses the DASH toolbox to implement a Kalman Filter for a time step of the reconstruction. The function allows you to specify the time slice, ensemble/set of estimates, R values, and climate model runs to use as ensemble members.

The folder may also hold `.mat` files, which contain pre-computed Kalman filter outputs from DASH.

### reconstructions
This folder holds the function `exportReconstruction`. This function exports assimilation outputs from the DASH toolbox to NetCDF. It regrids assimilated state vector variables back onto spatial grids, and combines outputs from preindustrial, mid-Pliocene, and early-Pliocene time slices. The folder may also hold NetCDF `.nc` files with pre-built reconstructions.
