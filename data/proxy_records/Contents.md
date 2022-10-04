# proxy_records
Contains raw proxy records and code used to format the records in preparation for assimilation.


### Contents

* raw
    The `raw` folder contains the raw proxy records. It consists of several subfolders, each holding proxy records of a specific proxy type. Each subfolder holds a number of CSV files - each CSV file holds the record for a specific proxy site. See `raw/Contents.md` for additional details about the raw proxy records.

* proxyData.m
    This class contains the code used to format the raw proxy records in preparation for assimilation. The main task involved is time-averaging the raw proxy data in the assimilation time slices. You can edit the class properties to change the time-averaging used for the assimilation. See the class help text for more details. To format the proxy data, run the `proxyData.organize` method. See its help section for additional details.

* formatted_proxies.nc
    This NetCDF file contains the formatted proxy data. This is the data file used as input to the DASH code for the assimilation.