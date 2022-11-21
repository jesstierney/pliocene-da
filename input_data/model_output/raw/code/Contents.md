# Climate Model Output Processing Code
This folder contains Matlab code used to process and validate raw climate model output. See the help text / documentation of these contents for additional details

### Pre-processing utilities
* `+load`: A package with functions used to load raw variables from climate model NetCDF files.
* `+regrid`: A package with functions used to map variables to a common spatial grid
* `exportNetCDF.m`: Writes NetCDF files containing the processed variables from a climate model run
* `processVariables.m`: Computes monthly climatologies, regrids to a common spatial grid, and applies unit conversions to a set of raw climate model output variables

### Validation Utilities
* `validateUnits.m`: Used to check that the NetCDF variables all use the same units.
* `plotVariable.m`: Used to visualize pre-processed data



