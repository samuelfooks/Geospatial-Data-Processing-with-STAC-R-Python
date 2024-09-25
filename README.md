#  EDITO STAC TOOLs

### Description
This is a small repository that gives a few short examples of basic scripts on how to access STAC catalogs.  One such catalog featuring an active STAC API service 'https://catalog.dive.edito.eu/'. 
And a static STAC catalog https://s3.waw3-1.cloudferro.com/emodnet/bio_oracle/stac/catalog.json

In these scripts, it goes through accessing the different parts of the STAC catalog structure:
 internal catalogs
 collections
 items
 assets

Special attention is given to accessing the ARCO assets, specifically Zarr and Parquet assets.  As these assets are Cloud Optimized and can be subsetted and utilized easily for further processing/modelling

## search_edito_stac_zarr_assets.ipynb

This notebook is a scrolling tutorial on how to go through a STAC catalog using pystac-client.  Go through internal catalogs, find a specific collection based on the variables you are interested in.  Then select a STAC item from a given time period and given geographic range, and look up the Analysis Ready Cloud Optimized assets for each item.

You can then subset each asset and get very select data from what are otherwise large and cumbersome datasets from different sources.


### temperature_zarr_biooracle_stac.ipynb

This script fetches and processes temperature data from the Bio-Oracle STAC catalog. It performs the following steps:


### TODO

search_biooracle_stac_zarr_assets.py


### Dependencies

for python users

pip install -r requirements.txt

for R users

library(httr)
library(jsonlite)
library(glue)
library(dplyr)
library(lubridate)
library(tidyr)
library(rstac)
library(purrr)


## Description
This script is useful for researchers and data scientists who need to access and process temperature data from the Bio-Oracle STAC catalog.