# Geospatial Data Processing with STAC using Python and R

### Description
This is a small repository that gives a few short examples of basic scripts on how to access Spatial Temporal Asset Catalogs(STAC) catalogs. 

STAC Documentation https://stacspec.org/en

Quick Overview
STAC (Spatial Temporal Asset Catalog): STAC is a specification for sharing geospatial data. It describes catalogs that contain collections of spatial-temporal data. Each collection holds items, which link to actual data assets like Zarr or Parquet files.

ARCO Data: Analysis Ready Cloud Optimized (ARCO) data are datasets designed for efficient access and processing in cloud environments. Common formats are Zarr and Parquet, which allow users to easily subset and process large datasets.

STAC Endpoints:

- Active STAC API: https://api.dive.edito.eu/ – A live API where you can make queries to search and filter data.
- Static STAC JSON: https://s3.waw3-1.cloudferro.com/emodnet/bio_oracle/stac/catalog.json – A static catalog stored in JSON format for browsing data without an API.


STAC Object Summary:

Catalog: A root structure containing links to collections.
Collection: A dataset group containing geospatial items.
Item: A spatial-temporal object that includes metadata about specific data assets.
Asset: The actual data file (e.g., a Zarr file) linked within an item.
This setup allows easy access to large datasets, especially cloud-optimized formats like Zarr, making it perfect for researchers processing environmental data at scale.


### search_edito_stac_zarr_assets.ipynb

This notebook is a scrolling tutorial on how to go through a STAC catalog using pystac-client.  
1. Using pystac-client we can look up all the collections in  https://apî.dive.edito.eu/.
2. Select collections based on the variables of interest.  In the notebook collections with: 'seabed_habitats', 'dissolved_oxygen', 'temperature' in the id are filtered.
3. Then using start_datetime and end_datetime properties of STAC Items to filter the items by time period
4. Find any items that have Analysis Ready Cloud Optimized assets (.parquet, .zarr), and make a Dataframe and save it to a csv.

You can then subset each asset and get very select data from what are otherwise large and cumbersome datasets from different sources.  

### subsetting_arco_data.ipynb

This notebook is in development but shows some ways to interact with zarr datasets and subset specific data and combine it with other subsetted ARCO data.
1. Open a csv containing links to ARCO assets
2. Find .zarr assets specifically
3. Subset these data products by asking the user for input for a specific parameter/variable from a geographic range.  And if other dimensions are present, make a selection in those dimensions to target a specific data slice (array)
4. Plot these arrays.


### search_edito_stac_temperature_zarr_R.ipynb
Notebook showing the some of the same functionality with rstac as with pystac-client
1. This script fetches zarr data from the EDITO STAC API https://catalog.dive.edito.eu/.  
2. Filter Function: Define a function to filter collections based on a keyword.
3. Retrieve collections from the STAC endpoint
4. Filter the collections based on the keyword 'temperature'.  Print these collections
5. Select a collection from the printed collections
6. Retreive the Items and their properties, including start_datetime, end_datetime, geometry, and assets.
7. If any assets are of the type '.zarr' save them in a dataframe along with the item properties.


### search_biooracle_stac_temperature_zarr_R.ipynb
Notebook showing how to parse a static json catalog using R packages.

1. Set the STAC catalog endpoint URL.
2. Fetch and parse catalog data.
3. Filter for collections related to "temperature."
4. Retrieve collection links and fetch collection metadata.
5. Extract items and filter by date or region.
6. Find and print Zarr asset links.


### Dependencies

```bash
pip install -r requirements.txt

R
install.packages(c('units', 'sf', 'httr', 'jsonlite', 'glue', 'dplyr', 'lubridate', 'tidyr', 'rstac', 'purrr'))
q()
```

If you have conda installed(recommended for full environment)
```bash
mamba env create -f environment.yml
```

### Limitations

This tutorial is meant to serve as a template for access a STAC and for the specifications of the EDITO STAC as of January 2025.  The composition of a STAC catalog is subject to change.  Use the principles of the tutorial to access STAC items and ARCO assets from the catalogs mentioned here, or elsewhere.   

## Authors

Samuel Fooks
