# Raw Climate Model Output Folder

This folder contains resources and tools used to preprocess the raw climate model output. The folder contains:

* A `code` folder,
* A subfolder for each climate model used in the assimilation, and
* `processModelOutput.m`

The code folder holds a number of utility functions used to process raw climate output. The climate model subfolders contain summaries of the raw output files used, as well as functions that process the data for each individual model run. The `processModelOutput.m` function runs the processing script for every model run used by the assimilation.

To rebuild the processed NetCDF files, you should
* Download the raw output files detailed in the climate model summaries,
* Add the raw output files to the active Matlab path,
* Add the `code` folder to the active Matlab path, and
* Run `processModelOutput` from the Matlab console

This will generate the processed NetCDF files in the current directory.


# Climate Model Subfolders

Each climate model subfolder contains:

* [A .csv file summarizing the raw data files for the model](#csv-files), and
* [The Matlab functions (.m files) used to pre-process the raw data](#matlab-functions)

The sources of the raw climate model output are also [summarized below](#data-sources).

----------------------------------------

### CSV Files
Each CSV file summarizes the raw data files used from the model. The summaries are grouped by experiment, and files within an experiment group are grouped by assimilated climate variable. Each summary includes the following comma separated values:

* [CMIP6 Name](#cmip6-name)
* [File](#file)
* [Experiment](#experiment)
* [Variable Name in File](#variable-name-in-file)
* [Lat Name](#lat-name)
* [Lon Name](#lon-name)
* [Grid Type](#grid-type)
* [Time Step](#time-step)
* [Layer](#layer)
* [Units](#units)


### CMIP6 Name
The name of a climate variable used for assimilation. Here, we use CMIP6 naming conventions for assimilated variables. Options are:

| Name | Description |
| ---- | ----------- |
| pr   | Total precipitation |
| tas  | Near surface air temperature |
| tos  | Sea surface temperature |
| sos  | Sea surface salinity |
| siconc | Sea ice area percentage |

In most cases, the summary for a variable will span a single line. However, if multiple files were used for the variable, then the summary will span multiple lines.


### File
The name of the raw data file. 

In some cases, multiple files were used for a single assimilated variable. (For example, the output from GISS-Model2 splits variables across two files). When this occurs, the multiple files are listed. for a single assimilation variable. In this case, multiple files are listed as per:
```
<first file>
<second file>
<etc>
```

Sometimes, a range of files were used for a single variable. (For example, precipitation output from HadCM3 is split across 100 files numbered from 000 to 099). When this occurs, files are denoted as:
```
<first file in range>
to 
<last file in range>"
```

Sometimes, a preprocessed variable is constructed from the sum of raw output variables. (For example, precipitation from CESM2 is the sum of the PRECC and PRECL raw output variables). When this occurs, files are denoted as:
```
  <file 1>
+ <file 2>
```


### Experiment
A tag that indicates the experiment associated with the raw output file. Options are as follows:

| Experiment | Description | Citation |
| ---------- | ----------- | -------- |
| E280       | A run with pre-industrial (1850 CE) boundary conditions | [Haywood et al., (2020)](https://doi.org/10.5194/cp-2019-145) |
| Eoi400     | A run with mid-Pliocene boundary conditions | [Haywood et al., (2020)](https://doi.org/10.5194/cp-2019-145) |
| pi.400     | (CESM2) A run with pre-industrial boundary conditions and 400 ppm CO2 | [Feng et al., (2022)](https://doi.org/10.1038/s41467-022-28814-7) |
| eo400.new  | (CESM2) Pliocene topography, geography and CO2 (400 ppm), but preindustrial vegetation and ice sheet | [Feng et al., (2022)](https://doi.org/10.1038/s41467-022-28814-7) |
| PreInd     | (CESM1.2.2) A pre-industrial control run | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |
| PlioB17    | (CESM1.2.2) A run with early-Pliocene boundary conditions | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |
| Plio       | (CESM1.2.2) A run with mid-Pliocene boundary conditions | [Ford et al., (2022)](https://doi.org/10.1038/s41561-022-00978-3) |



### Variable Name in File
The name of the variable in the raw output file that holds the climate field.

In some cases, an assimilated variable is derived as the sum of two variables in a raw output file. (For example, precipitation for CESM1.2.5 is derived as the sum of the PRECC and PRECL variables in each raw output file). In this case, variable names are denoted as:
```
  <variable 1>
+ <variable 2>
```

### Lat Name
The name of the variable in the raw output file that holds latitude metadata.

### Lon Name
The name of the variable in the raw output file that holds longitude metadata.

### Grid Type
Indicates the type of spatial grid used in the raw output file. Options are:

| Grid Type | Description |
| --------- | ----------- |
| Curvilinear | Data has explicit latitude and longitude dimensions. |
| Tripolar | Data is organized on a tripolar grid. |
| Regridded | Data has been regridded to a 1x1 spatial field. |

### Time Step
Indicates the time step of data in the raw output file. Options are:

| Time Step | Description |
| --------- | ----------- |
| Monthly | Monthly time series |
| Climatology | Monthly climatology |

### Layer
Some output files include output from multiple layers (i.e. different heights or depths). This field indicates which layer holds the required data. If an output file does not have multiple layers, then NA is used as a placeholder value.

### Units
Indicates the units of the climate field in the raw output file.

----------------------------------------

## Matlab Functions
Each folder also contains several Matlab functions, which were used to pre-process the raw climate model output. The naming convention is `<model name>_<experiment tag>.m`. For example, the `COSMOS_eoi400.m` function was used to preprocess the COSMOS EOI400 run.

The Matlab functions follow this general procedure:

1. Load raw data
2. If applicable, extract data from the appropriate height/depth layer
3. If necessary, compute 100 year climatology
4. Regrid climatology to a 1x1 curvilinear spatial grid.
    - Uses linear interpolation
    - Uses NaN values for points outside of the original spatial grid (does not extrapolate)
5. Export to NetCDF

To run the functions youself, you should:
* Download the raw data files, 
* Add the raw data files to your Matlab path
* Add the functions to your Matlab path
* Enter the function name in the Matlab console

Each function will produce a NetCDF file that matches the name of the function (i.e. `<model name>_<experiment>.nc`). The file contains the pre-processed variable for the associated model/experiment.

Alternatively, you can run the `processModelOutput.m` function to generate the NetCDF file for every climate model run used in the assimialtion.

----------------------------------------

## Data sources
The following table summarizes the source of the raw data files for each model:

|   Model     | Source |
| ----------- | ------ |
|*CCSM4-NCAR   |        |
|CCSM4-UoT    | PlioMIP2 Data Server (via Globus) |
|*CESM1.0.5    | PlioMIP2 Data Server (via Globus) |
|CESM1.2      | Sent by Natalie Burls |
|CESM2        | Sent by Ran Feng, also available on PlioMIP2 Data Server and ESGF - CMIP6 Archive |
|COSMOS       | PlioMIP2 Data Server (via Globus) |
|EC-Earth3.3  | Earth Systen Grid Federation - CMIP6 Data Search (via HTTP download scripts) |
|GISS-ModelE2 | Earth System Grid Federation - CMIP6 Data Search |
|HadCM3       | PlioMIP2 Data Server (via Globus) |
|HadGM3       | PlioMIP2 Data Server (via Globus) |
|IPSL-CM5A    | PlioMIP2 Data Server (via Globus) |
|IPSL-CM5A2   | PlioMIP2 Data Server (via Globus) |
|IPSL-CM6A    | Earth System Grid Federation - CMIP6 Data Search |
|MIROC4m      | PlioMIP2 Data Server (via Globus) |
|*MRI-CGCM2.3  | PlioMIP2 Data Server (via Globus) |
|NorESM1-F    | PlioMIP2 Data Server (via Globus) |
|NorESML      | PlioMIP2 Data Server (via Globus) |
| *           | Indicates model is missing data and not currently used for assimilation|



### Missing Data
This section summarizes any missing data fields

* MRI-CGCM2.3 - Missing SSS data     (as of Nov. 7, 2022)
* CCSM4-NCAR  - (Data probably exists, but the Globus repository is a mess and needs to be parsed)
* CESM1.0.5   - Missing monthly SOS data. Current data only has annual averages






