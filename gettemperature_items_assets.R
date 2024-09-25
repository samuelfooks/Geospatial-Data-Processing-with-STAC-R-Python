library(rstac)
library(purrr)

# Define STAC endpoint URL
stac_endpoint_url <- 'https://catalog.dive.edito.eu/'

# Function to filter collections by keyword in ID or title
filter_collections_by_keyword <- function(collections, keyword) {
  Filter(function(col) {
    grepl(keyword, col$id, ignore.case = TRUE) |
      grepl(keyword, col$title, ignore.case = TRUE)
  }, collections$collections)
}

# Perform a request to get all collections in the catalog
collections <- stac(stac_endpoint_url) %>%
  collections() %>%
  get_request()

# Filter collections that contain 'temperature' in their ID or title
filtered_collections <- filter_collections_by_keyword(collections, "temperature")

# Print filtered collections and allow user to choose one
cat("Filtered collections:\n")
for (i in seq_along(filtered_collections)) {
  cat(i, ": ", filtered_collections[[i]]$title, " (ID: ", filtered_collections[[i]]$id, ")\n", sep = "")
}

# Prompt user to choose a collection by index
cat("\nEnter the number of the collection you want to choose: ")
chosen_index <- as.integer(readLines(n = 1))

if (!is.na(chosen_index) && chosen_index >= 1 && chosen_index <= length(filtered_collections)) {
  chosen_collection <- filtered_collections[[chosen_index]]
  col_id <- chosen_collection$id
  col_title <- chosen_collection$title
  cat("You chose:\n")
  cat("Collection ID:", col_id, "\n")
  cat("Collection Title:", col_title, "\n")
  # Create STAC object
  stac_obj <- stac(stac_endpoint_url)
  # Retrieve items for the chosen collection
  items <- stac_obj %>%
    stac_search(collections = col_id) %>%
    get_request()
  
  cat("Number of items:", length(items$features), "\n")  # Count item features
  
  # Print item IDs
  cat("Items in the chosen collection:\n")
  for (item in items$features) {
    cat("Item ID: ", item$id, "\n")
    cat("Assets:\n")
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
    }
  }
} else {
  cat("Invalid choice. Exiting.\n")
}

  