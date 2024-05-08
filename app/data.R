library('dplyr')
library('lubridate')
import::from(rlang, "sym", "!!")


#' Rename Longitudinal and Latitudinal Columns
#'
#' This function renames longitudinal and latitudinal columns in a dataset according to a predefined mapping.
#'
#' @param data A data frame containing longitudinal and latitudinal columns to be renamed.
#' @return A modified version of the input data frame with renamed columns.
#' @examples
#' # Example usage:
#' data <- data.frame(longitude = c(1, 2, 3), latitude = c(4, 5, 6))
#' renamed_data <- rename_long_lat_columns(data)
#' print(renamed_data)
#' # Output:
#' #   lng lat
#' # 1   1   4
#' # 2   2   5
#' # 3   3   6
#' @export
rename_long_lat_columns <- function(data){

  columns_to_rename <- c("longitude" = "lng", "long" = "lng", "latitude" = "lat")
  for (old_name in names(data)) {
    if (old_name %in% names(columns_to_rename) && old_name %in% names(data)) {
      new_name <- columns_to_rename[old_name]
      names(data)[names(data) == old_name] <- new_name
    }
  }

  return(data)
}



#' Filter out rows with invalid longitude and latitude values
#'
#' This function takes a dataframe as input and filters out rows where
#' the longitude (lng) and latitude (lat) values are outside the valid
#' ranges (-180 to 180 for lng and -90 to 90 for lat).
#'
#' @param dataframe The dataframe containing longitude and latitude values.
#'
#' @return A dataframe with rows filtered based on valid lng and lat values.
#'
#' @examples
#' # Create a sample dataframe
#' dataframe <- data.frame(
#'   lng = c(10, 200, -100, 50),
#'   lat = c(30, 40, 100, -80)
#' )
#'
#' # Filter out rows with invalid lng and lat values
#' filtered_data <- filter_valid_coordinates(dataframe)
#'
#' @export
filter_valid_coordinates <- function(dataframe) {
  # Filter out rows with valid lng and lat values
  filtered_data <- dataframe %>%
    filter(between(lng, -180, 180) & between(lat, -90, 90))

  return(filtered_data)
}



open_goeland_csv <- function(file_path, label_col, popup_col, sep = ';') {
  # Read CSV file
  data <- read.csv(file_path, stringsAsFactors = FALSE, sep = sep)


  # Rename longitude and latitude columns to lng and lat if they exist
  data <- rename_long_lat_columns(data)

  # filter valid coordinate only
  data <- filter_valid_coordinates(data)

  # Select specified columns using dplyr
  selected_data <- data %>%
    dplyr::mutate(
      annee = as.integer(annee),
      label_col = !!sym(label_col),
      popup_col = !!sym(popup_col)
      ) %>%
    dplyr::select(.data$label_col, .data$popup_col, 'lng', 'lat', 'annee') %>%
    dplyr::filter(.data$annee >= 2017 & .data$annee <= lubridate::year(Sys.Date()))%>%
    unique()

  return(selected_data)
}


open_bigfoot_csv <- function(file_path, label_col, popup_col, sep = ';') {
  # Read CSV file
  data <- read.csv(file_path, stringsAsFactors = FALSE, sep = sep)

  # Rename longitude and latitude columns to lng and lat if they exist
  data <- rename_long_lat_columns(data)

  # filter valide coordinate only
  data <- filter_valid_coordinates(data)

  # Select specified columns using dplyr
  selected_data <- data %>%
    dplyr::mutate(annee = lubridate::year(timestamp),
                  label_col = !!sym(label_col),
                  popup_col = !!sym(popup_col)) %>%
    dplyr::select(.data$label_col, .data$popup_col, 'lng', 'lat', 'annee') %>%
    unique()

  return(selected_data)
}
