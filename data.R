library('dplyr')
library('lubridate')


open_csv_select_columns <- function(file_path, selected_columns, sep = ';') {
  # Read CSV file
  data <- read.csv(file_path, stringsAsFactors = FALSE, sep = sep)

  # Rename longitude and latitude columns to lng and lat if they exist
  columns_to_rename <- c("longitude" = "lng", "long" = "lng", "latitude" = "lat")
  for (old_name in names(data)) {
    if (old_name %in% names(columns_to_rename) && old_name %in% names(data)) {
      new_name <- columns_to_rename[old_name]
      names(data)[names(data) == old_name] <- new_name
    }
  }

  # Select specified columns using dplyr
  selected_data <- data %>%
    select(selected_columns, 'lng', 'lat', 'annee') %>%
    filter(annee >= 2017 & annee <= lubridate::year(Sys.Date()))%>%
    mutate(annee = as.integer(annee))%>%
    unique()


  return(selected_data)
}

# data <- open_csv_select_columns(
#   './R/sterilisations-de-nids-de-goelands-ville-de-lorient.csv',
#   selected_columns = c(
#     "nid_support"
#   ),
#   sep = ";"
# )
