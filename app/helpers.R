customMarkerColor <- function(label_col, colors) {
  # Map label_col to corresponding colors
  color_index <- match(label_col, unique(label_col))

  # Return corresponding colors based on label_col
  return(unname(colors[color_index]))
}


generate_button_card <- function(label, color, image_url) {
  button_card <- paste0('
    <div class="card" style="background-color: ', color, ';">
      <div class="card-body" style="display: flex; flex-direction: column; align-items: center;">
        <button type="button" class="btn btn-primary btn-lg" style="width: 100%;">
          <img src="', image_url, '" class="card-img-top" alt="..." style="max-height: 200px; object-fit: contain;">
          <span>', label, '</span>
        </button>
      </div>
    </div>')

  return(button_card)
}



generate_button_set <- function(labels, colors, image_urls) {
  if (length(labels) != length(colors) || length(labels) != length(image_urls)) {
    stop("Input lists must be of equal length")
  }

  button_set <- '<div style="display: flex; flex-wrap: wrap; justify-content: flex-start;">'

  for (i in seq_along(labels)) {
    button_id <- paste0("button_", gsub("\\s+", "_", tolower(labels[i])))
    button_color <- colors[i]
    button_hover_color <- adjustcolor(button_color, red.f = 0.9, green.f = 0.9, blue.f = 0.9)  # Darken the color slightly for hover
    button_click_color <- adjustcolor(button_color, red.f = 0.7, green.f = 0.7, blue.f = 0.7)  # Darken the color more for click
    button_set <- paste0(button_set, '
      <div class="card" style="background-color: ', button_color, '; width: 100px; height: 100px; margin: 5px; border-radius: 10px; display: flex; align-items: center;">
        <div class="card-body" style="flex-grow: 1; display: flex; flex-direction: column; align-items: center;">
          <button id="', button_id, '" type="button" class="btn btn-primary btn-lg" style="width: 100px; height: 100px; border-radius: 10px; background-color: ', button_color, '">
            <div style="display: flex; flex-direction: column; justify-content: space-around; align-items: center; flex-grow: 1;">
              <span style="font-size: 10px;">', labels[i], '</span> <!-- Adjust font size here -->
              <img src="', image_urls[i], '" class="card-img-top" alt="..." style="max-height: 60px; object-fit: contain; box-shadow: 0 0 20px rgba(0, 0, 0, 0.5) inset;"> <!-- Adjust shadow here -->
            </div>
          </button>
        </div>
      </div>
      <style>
        #', button_id, ':hover {
          background-color: ', button_hover_color, ' !important; /* Change the color on hover */
        }
        #', button_id, ':active {
          background-color: ', button_click_color, ' !important; /* Change the color on click */
        }
      </style>')
  }

  button_set <- paste0(button_set, '</div>')

  return(button_set)
}





generate_card_set <- function(labels, colors, image_urls, descriptions) {
  if (length(labels) != length(colors) || length(labels) != length(image_urls) || length(labels) != length(descriptions)) {
    stop("Input lists must be of equal length")
  }

  card_set <- '<div style="display: flex; flex-wrap: wrap; justify-content: flex-start;">'

  for (i in seq_along(labels)) {
    card_id <- paste0("card_", gsub("\\s+", "_", tolower(labels[i])))
    card_color <- colors[i]
    card_set <- paste0(card_set, '
      <div class="flip-card" style="width: 100px; height: 100px; margin: 5px; perspective: 1000px;">
        <div class="flip-card-inner">
          <div class="flip-card-front" style="background-color: ', card_color, '; border-radius: 10px; display: flex; align-items: center; justify-content: center;">
            <span style="font-size: 12px;">', labels[i], '</span>
            <img src="', image_urls[i], '" alt="..." style="max-height: 60px; object-fit: contain;">
          </div>
          <div class="flip-card-back" style="border-radius: 10px; display: flex; align-items: center; justify-content: center;">
            <span style="font-size: 11px;">', labels[i], '</span>
            <p style="font-size: 9px;">', descriptions[i], '</p>
          </div>
        </div>
      </div>')
  }

  card_set <- paste0(card_set, '</div>')

  return(card_set)
}





returnNull <- function() {
  return(NULL)
}



