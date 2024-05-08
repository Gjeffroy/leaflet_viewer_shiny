# Shiny App: Seagull Settlement and Bigfoot Sightings Visualization

This Shiny app allows users to visualize two datasets: Seagull settlements in Lorient and Bigfoot sightings. Users can explore these datasets over time using the animation function of a slider. Additionally, the app clusters data points and shows the density of data points to provide a comprehensive view of the spatial distribution of the phenomena.

## Overview

add gif

## Features

- **Animate Through Time**: Use the slider to animate the passage of time, witnessing the shifting patterns of seagull colonies and Bigfoot encounters.
- **Clustered Data Points**: Clusters of data points allow for a clearer view of dense areas, providing a more comprehensive understanding of the distribution patterns.
- **Density Visualization**: Dive deeper into the density of data points with density overlays, revealing hotspots and trends in both seagull and Bigfoot activity.

## Datasets

1. **Seagull Settlements in Lorient:** This dataset contains information about the settlements of Seagulls in the Lorient region. It includes spatial coordinates and timestamps.
2. **Bigfoot Sightings:** This dataset contains reports of Bigfoot sightings across different locations. It includes spatial coordinates and timestamps.


## How to Use

1. **Select Dataset**: Choose between Seagull Settlement and Bigfoot Sightings using the dropdown menu.
2. **Time Animation**: Adjust the slider range and press play to witness the evolution of data over time.
3. **Cluster View**: Toggle cluster markers on or off to manage data density.
4. **Density Overlay**: Activate the density overlay to explore the concentration of data points.

## Installation

To run this Shiny app locally, follow these steps:

1. Clone the repository:
```bash
git clone https://github.com/your_username/your_repository.git
```

2. Install the renv package in R:
```R
install.packages('renv')
```

3. Load the renv library and upgrade your project's packages:
```R
library(renv)
renv::upgrade()
renv::activate()
renv::restore()
```

4. Activate the project's environment and restore the necessary packages:
```R
renv::activate()
renv::restore()
```

5. Load the Shiny library and run the Shiny app by executing the run_app.R file:
```R
library(shiny)
runApp("run_app.R")
```



## License

This project is licensed under the [MIT License](LICENSE). Feel free to use and modify this code for your own purposes.
