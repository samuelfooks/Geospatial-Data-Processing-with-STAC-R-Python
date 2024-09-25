import pystac
import xarray as xr
import pandas as pd
from datetime import datetime, date
from pystac_client import Client

# STAC API root URL
URL = 'https://s3.waw3-1.cloudferro.com/emodnet/bio_oracle/stac/catalog.json'

# custom headers
headers = []

# Open the Catalog
cat = Client.open(URL, headers=headers)
print(cat)

choosen_catalog = 'chlorophyll'

choosen_collection = 'chl'

for catalog in cat.get_children():
    if choosen_catalog in catalog.id:
        print(catalog.id)
        for collection in catalog.get_children():
            if choosen_collection in collection.id:
                print(collection.id)
                for item in collection.get_items():
                    print(item.id)
                    print(item.assets)
                    break
        break

# List the collections
collections = list(cat.get_all_collections())
print(f'Found {len(collections)} collections')
for collection in collections:
    if 'chlorophyll' in collection.id:
        print(collection.id)
        for item in collection.get_all_items():
            print(item.id)
            print(item.assets)
            break

# Make a list for item assets
all_items_assets = []

# Loop through the collections
for collection in collections:

    # look for chlorophyll collections
    if 'chl' in collection.id:
        # Loop through the items
        for item in collection.get_items():
            assets_list = []
            # Loop through the assets
            for asset_key, asset in item.assets.items():
                # Check if the asset is a zarr or parquet file
                if asset.href.endswith('.zarr') or asset.href.endswith('.zarr/') or asset.href.endswith('.parquet'):
                    # Append asset information to the list
                    assets_list.append({'Collection ID': collection.id, 'Item ID': item.id, 'Asset Key': asset_key, 'Asset Href': asset.href})
            
            # Append item information to the list
            all_items_assets.extend(assets_list)

            break    
df = pd.DataFrame(all_items_assets)
print(df.head())
