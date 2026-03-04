library(tidyverse)
library(htmltools)
library(leaflet)
library(sf)
# Define server logic for random distribution app ----
server <- function(input, output) {
  # mw_admin <- st_read("C:/Users/LENOVO/Documents/GIS_DATASETS/mwi_admin2_em.shp")
  # mwi_nutrition <- st_read("C:/Users/LENOVO/Documents/__CODE/R/nutrition/mw_adm_stunting.shp")
  mwi_nutrition <- st_read("C:/Users/LENOVO/Documents/__CODE/R/nutrition/nutrition_app/data/mw_nutrition_data.geojson")
  
  

# ---------------------------------------------------------------------------
# ***************** OVERVIEW SECTION****************************
  # Generate a plot of the data ----
  nutrition_trend <- readxl::read_excel("C:/Users/LENOVO/Documents/__CODE/R/nutrition/nutrition_app/data/mdhs_datasets.xlsx", sheet = "nutrition_trend")
  
  # ---------- Plotting the trend
  nutrition_long <- nutrition_trend %>%
    pivot_longer(cols = c(Stunted, Overweight, Wasted),
                 names_to = "Indicator",
                 values_to = "Percentage")

  
  # Create the plot
  output$trend_plot <- renderPlot({ 
  ggplot(nutrition_long, aes(x = MDHS_Series, y = Percentage, 
                             color = Indicator, group = Indicator)) +
    geom_line(linewidth = 0.5) +
    geom_point(size = 2) +
    labs(
      title = "Trends in Child Malnutrition in Malawi (1992-2024)",
      #subtitle = "Data from Malawi Demographic and Health Surveys",
      x = "Year",
      y = "Percentage (%)",
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
  
  # ---------another plot, a bar chart
  top5 = mwi_nutrition |> arrange(desc(Percentage_below_..2SD_stunting))
  top5 <- top5[1:10, ]
  
  output$top5_stunting <- renderPlot({
    ggplot(data = top5, aes(x = reorder(adm2_name,-Percentage_below_..2SD_stunting ), 
                            y = Percentage_below_..2SD_stunting)) +
      geom_col() + 
      labs(title = "Districts where stunting was highest",
           x = "District", y = "Stunting (%)") + theme_minimal()
    
  })
  

  
  
  
# ---------------------------------------------------------------------------
# ***************** GEOGRAPHIC DISPARITIES SECTION****************************
  
  # making a map plot 
  pal <- colorBin(palette = "Greens", bins = 4,
                      domain = mwi_nutrition$Percentage_below_..2SD_stunting, na.color = "black")
  
  # concatenating labels for multiple labels
  mwi_nutrition$label_stunting <- paste(
    sep = "<br/>",
    strong("Name: "), mwi_nutrition$adm2_name,
    strong("Stunting: "),mwi_nutrition$Percentage_below_..2SD_stunting
  )
  
  
  # ---------------------Map showing Stunting
  output$map_stunting <- renderLeaflet(
    
    map <- leaflet(data = mwi_nutrition) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal(Percentage_below_..2SD_stunting),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(label_stunting, HTML)   ) |> 
      
      addLegend(
        pal = pal,
        values = ~Percentage_below_..2SD_stunting, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Stunting 2024"
      )
  )
  
  # ---------------------Map showing Wasting
  
  pal2 <- colorBin(palette = "Blues", bins = 4,
                  domain = mwi_nutrition$Percentage_below_.2SD_wasting, na.color = "black")
  
  
  # concatenating labels for multiple labels
  mwi_nutrition$label_wasting <- paste(
    sep = "<br/>",
    strong("Name: "), mwi_nutrition$adm2_name,
    strong("Wasting: "),mwi_nutrition$Percentage_below_.2SD_wasting
  )
  
  output$map_wasting <- renderLeaflet(
    
    map <- leaflet(data = mwi_nutrition) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal2(Percentage_below_.2SD_wasting),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(label_wasting, HTML)   ) |> 
      
      addLegend(
        pal = pal2,
        values = ~Percentage_below_.2SD_wasting, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Wasting 2024"
      )
  )
  
  # ---------------------Map showing Underweight
  
  pal3 <- colorBin(palette = "Reds", bins = 4,
                  domain = mwi_nutrition$percentage.below_.2SD_underweight, 
                  na.color = "black")
  
  # concatenating labels for multiple labels
  mwi_nutrition$label_underweight <- paste(
    sep = "<br/>",
    strong("Name: "), mwi_nutrition$adm2_name,
    strong("Underweight: "),mwi_nutrition$percentage.below_.2SD_underweight
  )
  
  output$map_overweight <- renderLeaflet(
    
    map <- leaflet(data = mwi_nutrition) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal3(percentage.below_.2SD_underweight),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(label_underweight, HTML)   ) |> 
      
      addLegend(
        pal = pal3,
        values = ~percentage.below_.2SD_underweight, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Underweight 2024"
      )
  )
  
}