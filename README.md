#  EDITO STAC TOOLs

### Description
This is a small repository that gives a few short examples of basic scripts on how to access Spatial Temporal Asset Catalogs(STAC) catalogs. 

STAC Documentation https://stacspec.org/en

Quick Overview
STAC (Spatial Temporal Asset Catalog): STAC is a specification for sharing geospatial data. It describes catalogs that contain collections of spatial-temporal data. Each collection holds items, which link to actual data assets like Zarr or Parquet files.

ARCO Data: Analysis Ready Cloud Optimized (ARCO) data are datasets designed for efficient access and processing in cloud environments. Common formats are Zarr and Parquet, which allow users to easily subset and process large datasets.

STAC Endpoints:

Active STAC API: https://catalog.dive.edito.eu/ – A live API where you can make queries to search and filter data.
Static STAC JSON: https://s3.waw3-1.cloudferro.com/emodnet/bio_oracle/stac/catalog.json – A static catalog stored in JSON format for browsing data without an API.


STAC Object Summary:

Catalog: A root structure containing links to collections.
Collection: A dataset group containing geospatial items.
Item: A spatial-temporal object that includes metadata about specific data assets.
Asset: The actual data file (e.g., a Zarr file) linked within an item.
This setup allows easy access to large datasets, especially cloud-optimized formats like Zarr, making it perfect for researchers processing environmental data at scale.


## search_edito_stac_zarr_assets.ipynb

This notebook is a scrolling tutorial on how to go through a STAC catalog using pystac-client.  Go through internal catalogs, find a specific collection based on the variables you are interested in.  Then select a STAC item from a given time period and given geographic range, and look up the Analysis Ready Cloud Optimized assets for each item.

You can then subset each asset and get very select data from what are otherwise large and cumbersome datasets from different sources.

### search_edito_stac_temperature_zarr.R

This script fetches zarr data from the EDITO STAC API https://catalog.dive.edito.eu/.  Based on an input string it will retreive all the collections(variables) that contain items with data that have that variable. In the example, temperature is used.  Then there is a prompt for an index of the list of collections to choose from.  After this index is given, that collection is then parsed for all of its STAC items.  And if there is a Zarr dataset as an asset in that item it is put into a final output dataframe.


### search_biooracle_stac_temperature_zarr.R
This script fetches temperature data from the Bio-Oracle STAC catalog using a static JSON catalog. It searches for a collection of temperature data, retrieves relevant items, and filters them for Zarr assets. The major steps include:

1. Set the STAC catalog endpoint URL.
2. Fetch and parse catalog data.
3. Filter for collections related to "temperature."
4. Retrieve collection links and fetch collection metadata.
5. Extract items and filter by date or region.
6. Find and print Zarr asset links.


### Dependencies

for python users

pip install -r requirements.txt

for R users

install.packages(c('units', 'sf', 'httr', 'jsonlite', 'glue', 'dplyr', 'lubridate', 'tidyr', 'rstac', 'purrr'))

## In Development

subsetting_arco_data.ipynb

## Authors

Samuel Fooks