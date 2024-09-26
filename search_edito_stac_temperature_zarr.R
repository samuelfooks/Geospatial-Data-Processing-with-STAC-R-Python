library(rstac)
library(purrr)
 
# Define STAC endpoint URL
stac_endpoint_url <- 'https://catalog.dive.edito.eu/'

# Function to filter collections by keyword in ID or title. This function takes a list of collections and a keyword as input. It returns a list of collections where the keyword is found in either the ID or title of the collection.

filter_collections_by_keyword <- function(collections, keyword) {
  Filter(function(col) {
    grepl(keyword, col$id, ignore.case = TRUE) |
      grepl(keyword, col$title, ignore.case = TRUE)
  }, collections$collections)
}

# Perform a request to get all collections in the catalog
# This chain of functions sends a request to the STAC endpoint to retrieve all available collections.
collections <- stac(stac_endpoint_url) %>%
  collections() %>%
  get_request()

# Filter collections that contain 'temperature' in their ID or title
# This line filters the retrieved collections to only include those that have 'temperature' in their ID or title.

filtered_collections <- filter_collections_by_keyword(collections, "temperature")

# Print filtered collections and allow user to choose one
# This block prints the filtered collections and prompts the user to choose one by entering its index.

cat("Filtered collections:\n")
for (i in seq_along(filtered_collections)) {
  cat(i, ": ", filtered_collections[[i]]$title, " (ID: ", filtered_collections[[i]]$id, ")\n", sep = "")
}

# Prompt user to choose a collection by index

cat("\nEnter the number of the collection you want to choose: ")
chosen_index <- as.integer(readLines(n = 1))

# Check if the chosen index is valid
# If the user input is valid, retrieve and print details of the chosen collection.

if (!is.na(chosen_index) && chosen_index >= 1 && chosen_index <= length(filtered_collections)) {
  chosen_collection <- filtered_collections[[chosen_index]]
  col_id <- chosen_collection$id
  col_title <- chosen_collection$title
  cat("You chose:\n")
  cat("Collection ID:", col_id, "\n")
  cat("Collection Title:", col_title, "\n")
  
  # Create STAC object
  # This creates a STAC object to interact with the STAC API.
  stac_obj <- stac(stac_endpoint_url)
  
  # Retrieve items for the chosen collection
  # This chain of functions sends a request to retrieve items for the chosen collection.
  items <- stac_obj %>%
    stac_search(collections = col_id) %>%
    get_request()
  
  cat("Number of items:", length(items$features), "\n")  # Count item features

  # Create a dataframe to store item details
  # This block extracts item details and stores them in a dataframe.
  item_details <- data.frame(
    Collection_ID = character(),
    Item_ID = character(),
    Start_Datetime = character(),
    End_Datetime = character(),
    Geometry = character(),
    Arco_Asset = character(),
    stringsAsFactors = FALSE
  )
  # Print item IDs and their assets
  # This block prints the IDs of the items in the chosen collection and details of their assets.
  cat("Items in the chosen collection:\n")
  for (item in items$features) {
    cat("Item ID: ", item$id, "\n")
    cat("Start Datetime: ", item$properties$start_datetime, "\n")
    cat("End Datetime: ", item$properties$end_datetime, "\n")
    cat("Assets:\n")
    arco_asset <- NA
    for (asset_name in names(item$assets)) {
      asset <- item$assets[[asset_name]]
      cat("  Asset Name: ", asset_name, "\n")
      cat("    Href: ", asset$href, "\n")
      cat("    Type: ", asset$type, "\n")
      if (!is.null(asset$title)) {
        cat("    Title: ", asset$title, "\n")
      }
      if (!is.null(asset$description)) {
        cat("    Description: ", asset$description, "\n")
      }
      if (grepl("\\.zarr$|\\.parquet$", asset$href) && !grepl("datalab", asset$href)) {
        arco_asset <- asset$href
      }
    }
    
    # Extract properties and geometry
    start_datetime <- item$properties$start_datetime
    end_datetime <- item$properties$end_datetime
    geometry <- item$geometry
    
    # Add item details to the dataframe
    item_details <- rbind(item_details, data.frame(
      Collection_ID = col_id,
      Item_ID = item$id,
      Start_Datetime = start_datetime,
      End_Datetime = end_datetime,
      Geometry = toString(geometry),
      Arco_Asset = arco_asset,
      stringsAsFactors = FALSE
    ))
  }
  
  # Print item details dataframe
  print(item_details)
} else {
  cat("Invalid choice. Exiting.\n")
}