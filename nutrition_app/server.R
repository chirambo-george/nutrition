library(tidyverse)
library(htmltools)
library(leaflet)
library(sf)
# Define server logic for random distribution app ----
server <- function(input, output) {
  mw_admin <- st_read("C:/Users/LENOVO/Documents/GIS_DATASETS/mwi_admin2_em.shp")
  mw_admin_stunt <- st_read("C:/Users/LENOVO/Documents/__CODE/R/nutrition/mw_adm_stunting.shp")
  
  

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
  ggplot(nutrition_long, aes(x = MDHS_Series, y = Percentage, color = Indicator, group = Indicator)) +
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
  top5 = mw_admin_stunting |> arrange(desc(Prb.2SD))
  top5 <- top5[1:5, ]
  
  output$top5_stunting <- renderPlot({
    ggplot(data = top5, aes(x = adm2_nm, y = Prb.2SD)) +
      geom_col() + 
      labs(title = "Districts where stunting was highest",
           x = "District", y = "Stunting (%)")
    
  })
  

  
  
  
# ---------------------------------------------------------------------------
# ***************** GEOGRAPHIC DISPARITIES SECTION****************************
  
  # making a map plot 
  pal <- colorBin(palette = "Greens", bins = 4,
                      domain = mw_admin_stunt$Prb.2SD, na.color = "black")
  
  # concatenating labels for multiple labels
  mw_admin_stunt$combined_label <- paste(
    sep = "<br/>",
    strong("Name: "), mw_admin_stunt$adm2_nm,
    strong("Stunting: "),mw_admin_stunt$Prb.2SD
  )
  
  
  # ---------------------Map showing Stunting
  output$map_stunting <- renderLeaflet(
    
    map <- leaflet(data = mw_admin_stunt) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal(Prb.2SD),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(combined_label, HTML)   ) |> 
      
      addLegend(
        pal = pal,
        values = ~Prb.2SD, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Stunting 2024"
      )
  )
  
  # ---------------------Map showing Wasting
  
  pal2 <- colorBin(palette = "Blues", bins = 4,
                  domain = mw_admin_stunt$Prb.2SD, na.color = "black")
  
  output$map_wasting <- renderLeaflet(
    
    map <- leaflet(data = mw_admin_stunt) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal2(Prb.2SD),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(combined_label, HTML)   ) |> 
      
      addLegend(
        pal = pal2,
        values = ~Prb.2SD, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Wasting 2024"
      )
  )
  
  # ---------------------Map showing Underwight
  
  pal3 <- colorBin(palette = "Reds", bins = 4,
                  domain = mw_admin_stunt$Prb.2SD, na.color = "black")
  
  output$map_overweight <- renderLeaflet(
    
    map <- leaflet(data = mw_admin_stunt) |> 
      setView(33.78725, -13.36692, zoom = 6)|> 
      
      addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
               attribution = paste(
                 "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                 "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
               )) |>  
      
      addPolygons(
        fillColor = ~pal3(Prb.2SD),        # Customize the fill color
        color = "black",          
        weight = 1,                
        fillOpacity = 1,         
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE),
        
        label = ~lapply(combined_label, HTML)   ) |> 
      
      addLegend(
        pal = pal3,
        values = ~Prb.2SD, # Use tilde notation to reference the column
        position = "bottomleft",
        title = "Overweight 2024"
      )
  )
  
}