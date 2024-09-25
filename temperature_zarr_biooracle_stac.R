library(httr)
library(jsonlite)
library(glue)
library(dplyr)
library(lubridate)
library(tidyr)

# Base STAC endpoint
stac_endpoint_url <- "https://s3.waw3-1.cloudferro.com/emodnet/bio_oracle/stac/catalog.json"
# Extract the root by removing 'catalog.json'
stac_root <- dirname(stac_endpoint_url)


# Perform the request to get catalog data
response <- GET(stac_endpoint_url)
json_data <- fromJSON(content(response, as = "text", encoding = "UTF-8"))

# Filter catalogs within root STAC catalog based on string

catalog_selector = 'temperature'
selected_catalogs <- json_data$links[grep(catalog_selector, json_data$links, ignore.case = TRUE), ]
selected_catalogs_titles <- json_data$links[grep(catalog_selector, json_data$links$title, ignore.case = TRUE), ]
print(selected_catalogs_titles$title)

catalog_links = glue('{stac_root}/{selected_catalogs_titles$title}/catalog.json')

print(catalog_links)

# Loop through and print each catalog link
for (i in seq_along(catalog_links)) {
  print(catalog_links[i])
}

# Loop through and print each catalog json
for (i in seq_along(catalog_links)) {
  print(catalog_links[i])
  internal_catalog_response = GET(catalog_links[i])
  internal_catalog_json <- fromJSON(content(internal_catalog_response, as = "text", encoding = "UTF-8"))
  print(internal_catalog_json)
}

# loop through and get each collection from the 'oceantemperature' catalog
# then get all the items in the 'thetao_mean' collection

collection_selector = 'thetao_mean'

selected_collections <- list()
# Initialize an empty DataFrame to store item links
selected_collection_items <- data.frame(item_link = character(), stringsAsFactors = FALSE)

for (i in seq_along(catalog_links)){
  if (grepl('oceantemperature', catalog_links[i], ignore.case= TRUE)){
    cat_link = catalog_links[i]
    cat_response = GET(cat_link)
    cat_json <- fromJSON(content(cat_response, as = "text", encoding = "UTF-8"))
    links = cat_json$links$href
    for (j in seq_along((links))) {
        if (grepl('collection.json', links[i], ignore.case=TRUE)) {
          collection = gsub("^\\./", "", dirname(links[j]))
          selected_collections <- append(selected_collections, collection)
          print(collection)
        
        if (grepl(collection_selector, collection, ignore.case = TRUE)) {
          collection_link = glue('{dirname(cat_link)}/{collection}/collection.json')
          collection_json <- fromJSON(content(GET(collection_link), as ='text', encoding = 'UTF-8'))
          collection_links = collection_json$links
         
          
          # Find rows where 'item' is in the rel column
          matched_rows <- collection_links[grepl('item', collection_links$rel, ignore.case = TRUE), ]
          
          # If any matches are found, retrieve the href
          if (nrow(matched_rows) > 0) {
            for (k in seq_len(nrow(matched_rows))) {
              item_href <- matched_rows[k, "href"]
              item_title <- matched_rows[k, 'title']
              # Chop off the leading './' if it exists
              item_href <- gsub("^\\./", "", item_href)
              
              # Create the full item link
              item_link <- glue("{dirname(collection_link)}/{item_href}")
              item_link <- as.character(item_link)
              print(item_link)  # Print or store the item link as needed
              # Append the item link to the selected_collection_items DataFrame
              selected_collection_items <- rbind(selected_collection_items, data.frame(item_link = item_link, stringsAsFactors = FALSE))
              
            }
          } else {
            print(glue("No matches found for item: {item}"))
          }
        }
      }
    }
  }
}

# Function to fetch item JSONs
fetch_item_jsons <- function(selected_items_df) {
  # Initialize an empty list to store item JSON data
  item_json_list <- list()  
  
  for (i in seq_len(nrow(selected_items_df))) {
    item_link <- as.character(selected_items_df$item_link[i])  # Convert glue object to character
    print('printing link')
    print(item_link)
    
    # URL encode the item link
    encoded_item_link <- URLencode(item_link)
    
    item_response <- GET(encoded_item_link)
    
    if (http_status(item_response)$category == "Success") {
      item_json <- fromJSON(content(item_response, as = "text", encoding = "UTF-8"))
      print('item id')
      # Create a named list to collect item data
      item_data <- list()
      item_data$id <- item_json$id
      item_data$type <- ifelse(!is.null(item_json$type), item_json$type, NA)
      item_data$geometry <- ifelse(!is.null(item_json$geometry), toJSON(item_json$geometry), NA)  # Convert geometry to JSON string for consistency
      
      # Extract properties and assets dynamically
      if (!is.null(item_json$properties)) {
        for (prop in names(item_json$properties)) {
          item_data[[paste0("properties_", prop)]] <- ifelse(!is.null(item_json$properties[[prop]]), item_json$properties[[prop]], NA)
        }
      }
      
      if (!is.null(item_json$assets)) {
        for (asset in names(item_json$assets)) {
          asset_info <- item_json$assets[[asset]]
          item_data[[paste0("assets_", asset, "_href")]] <- ifelse(!is.null(asset_info$href), asset_info$href, NA)
          item_data[[paste0("assets_", asset, "_type")]] <- ifelse(!is.null(asset_info$type), asset_info$type, NA)
        }
      }
      
      # Add the data for this item to the list
      item_json_list[[i]] <- as.data.frame(item_data, stringsAsFactors = FALSE)  # Store the structured data frame
    }  else {
      print(glue("Failed to fetch item JSON for link: {item_link}"))
    }
  }
  
  # Combine all item data frames into one
  item_json_df <- bind_rows(item_json_list)  
  return(item_json_df)
}


# Filtering items based on date time ranges, asset links, and item IDs

# Fetch item JSONs using the selected_collection_items DataFrame
item_json_df <- fetch_item_jsons(selected_collection_items)

# Print the final DataFrame
print(item_json_df)
# Initialize an empty DataFrame to store all items

# Step 1: Filter items based on start and end dates
filtered_items_df <- item_json_df %>%
  filter(
    properties_start_datetime <= "2029-01-01T00:00:00Z" & 
      properties_end_datetime > "2080-01-01T00:00:00Z"
  )

# Step 2: Create a dataframe for items where 'ssp245' is in the ID
ssp245_items_df <- filtered_items_df %>%
  filter(grepl("ssp245", id))

# Step 3: Initialize an empty dataframe to store results
ssp245_zarr_assets_df <- data.frame()

# Get all columns with 'asset' in the column name
asset_cols <- filtered_items_df %>%
  select(contains("asset"))

# Loop through the asset columns from the item with ssp245 in the id to filter for '.zarr'
for (col in names(asset_cols)) {
  # Check each asset column for '.zarr' links
  zarr_assets_temp <- ssp245_items_df %>%
    select(id, !!sym(col)) %>%  # Dynamically select column
    filter(sapply(!!sym(col), function(x) grepl("\\.zarr$", x)))  # Filter for '.zarr'
  
  # Combine results
  ssp245_zarr_assets_df<- bind_rows(ssp245_zarr_assets_df, zarr_assets_temp)
}

# Display the results
print("Filtered Items (2030 to 2090):")
print(filtered_items_df)

print("Items with 'ssp245' in ID:")
print(ssp245_items_df)

print("Assets with '.zarr':")
print(ssp245_zarr_assets_df$assets_Zarr_href)

