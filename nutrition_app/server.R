library(tidyverse)
library(htmltools)
library(leaflet)
library(sf)
# Define server logic for random distribution app ----
server <- function(input, output) {
  mw_admin <- st_read("C:/Users/LENOVO/Documents/GIS_DATASETS/mwi_admin2_em.shp")
  mw_admin_stunt <- st_read("C:/Users/LENOVO/Documents/__CODE/R/nutrition/mw_adm_stunting.shp")
  
  # Generate a plot of the data ----
  nutrition_trend <- readxl::read_excel("C:/Users/LENOVO/Documents/__CODE/R/nutrition/nutrition_app/data/mdhs_datasets.xlsx", sheet = "nutrition_trend")
  
  # ---------- Plotting the trend
  nutrition_long <- nutrition_trend %>%
    pivot_longer(cols = c(Stunted, Overweight, Wasted),
                 names_to = "Indicator",
                 values_to = "Percentage")

  
  # Create the plot
  output$trend_plot <- renderPlot({ 
  ggplot(nutrition_long, aes(x = MDHS_Series, y = Percentage, color = Indicator, group = Indicator)) +
    geom_line(linewidth = 0.5) +
    geom_point(size = 2) +
    labs(
      title = "Trends in Child Malnutrition in Malawi (1992-2024)",
      #subtitle = "Data from Malawi Demographic and Health Surveys",
      x = "Year",
      y = "Percentage (%)"
    ) +
    scale_color_manual(values = c("Stunted" = "#4daf4a",
                                  "Wasted" = "#377eb8", 
                                  "Overweight" = "#e41a1c")) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      legend.position = "bottom"
    )
  })
  
  
  # making a map plot 
    pal <- colorNumeric(palette = "Greens", domain = mw_admin_stunt$Prb.2SD, na.color = "black")
  output$map <- renderLeaflet(
    
    map <- leaflet(data = mw_admin_stunt) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal(Prb.2SD),        # Customize the fill color
        color = "black",           # Customize the border color
        weight = 1,                # Customize the border width
        fillOpacity = 0.7,         # Customize fill opacity
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~adm2_nm    )
  )
  
  
  
}