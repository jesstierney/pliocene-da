# Raw Climate Model Output

This folder contains resources and tools used to preprocess the raw climate model output. The folder contains a subfolder for each climate model used in the assimilation.

Each climate model subfolder contains:

* [A .csv file summarizing the raw data files for the model](#csv-files), and
* [The Matlab functions (.m files) used to pre-process the raw data](#matlab-functions)

The sources of the raw climate model output are also [summarized below](#data-sources).

----------------------------------------

## CSV Files
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

* pr: Total precipitation
* tas: Near surface air temperature
* tos: Sea surface temperature
* sos: Sea surface salinity
* siconc: Sea ice area percentage

In most cases, the summary for a variable will span a single line. However, if multiple files were used for the variable, then the summary will span multiple lines. Names


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

* E280:                   A run with pre-industrial (1850 CE) boundary conditions
* Eoi400:                 A run with mid-Pliocene boundary conditions
* pi.400:    (CESM2 only) A run with pre-industrial boundary conditions and 400 ppm CO2
* eo400.new: (CESM2 only) Pliocene topography, geography and CO2 (400 ppm), but preindustrial vegetation and ice sheet


### Variable Name in File
The name of the variable in the raw output file that holds the climate field.

### Lat Name
The name of the variable in the raw output file that holds latitude metadata.

### Lon Name
The name of the variable in the raw output file that holds longitude metadata.

### Grid Type
Indicates the type of spatial grid used in the raw output file. Options are:

* Curvilinear: Data has explicit latitude and longitude dimensions.
* Tripolar:    Data is organized on a tripolar grid.
* Regridded:   Data has been regridded to a 1x1 spatial field.

### Time Step
Indicates the time step of data in the raw output file. Options are:

* Monthly:     Monthly time series
* Climatology: Monthly climatology

### Layer
Some output files include output from multiple layers (i.e. different heights or depths). This field indicates which layer holds the required data. If an output file does not have multiple layers, then NA is used as a placeholder value.

### Units
Indicates the units of the climate field in the raw output file.

----------------------------------------

## Matlab Functions
Each folder also contains several Matlab functions, which were used to pre-process the raw climate model output. Most climate models have two associated functions named `<model name>_preindustrial.m` and `<model name>_midpliocene.m`, which preprocess the data from the preindustrial (E280) and mid-Pliocene (Eoi400) experiments, respectively. 

The CESM2 folder also includes two additional functions `CESM2_eo400new.m` and `CESM2_pi400.m`, which pre-process data from those two experiments. Separately, the ECEarth-3.3 folder also includes two functions `download_ECEarth3.3_EOI400.m` and `download_ECEarth3.3_E280.m`, which were used to download raw output files from ESGF.

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

----------------------------------------

## Data sources
The following table summarizes the source of the raw data files for each model:

|   Model     | Source |
| ----------- | ------ |
|CCSM4-NCAR   | 
|CCSM4-UoT    |
|CESM1.0.5    | PlioMIP2 Data Server (via Globus) |
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
| *           | Indicates model is missing data |



### Missing Data
This section summarizes any missing data fields

MRI-CGCM2.3 - Missing SSS data     (as of Nov. 7, 2022)








