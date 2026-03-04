library(leaflet)
library(sf)

mw_admin <- st_read("C:/Users/LENOVO/Documents/GIS_DATASETS/mwi_admin2_em.shp")

map <- leaflet(data = mw_admin) |> 
  setView(33.78725, -13.36692, zoom = 6)|> 
  
  addTiles("https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png",
                       attribution = paste(
                         "&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap</a> contributors",
                         "&copy; <a href=\"https://cartodb.com/attributions\">CartoDB</a>"
                       )) |>  
  
  addPolygons(
    fillColor = "#f3f3f3",        # Customize the fill color
    color = "black",           # Customize the border color
    weight = 1,                # Customize the border width
    fillOpacity = 0.7,         # Customize fill opacity
    highlight = highlightOptions(
    weight = 5,
    color = "#666",
    fillOpacity = 0.9,
    bringToFront = TRUE),
    
  label = ~adm2_name      )  



map



# cleaning the sahpefile dataset and joining nutrition tables
view(mw_admin)
colnames(mw_admin) 
mw_admin <- mw_admin |> dplyr::select(-c("adm2_name1","adm2_name2","adm2_name3",
                                         "adm1_name1","adm1_name2","adm1_name3",
                                         "adm0_name1","adm0_name2","adm0_name3",
                                         "lang1","lang2","lang3",
                                         
                                         ))


# --- creating a new mw_admin object

mdhs_datasets <- read_excel("nutrition_app/data/mdhs_datasets.xlsx", 
                            sheet = "aggregates")
mw_admin_stunting <- left_join(mw_admin, mdhs_datasets, by = c("adm2_name" ="District"))

# sf::st_write(mw_admin_stunting, "nutrition_app/data/mw_adm_stunting.shp")
st_write(mw_admin_stunting, dsn = "nutrition_app/data/mw_nutrition_data.geojson", driver = "GeoJSON")


mw_admin_stunting <- sf::st_read("nutrition_app/data/mw_adm_stunting.shp")
colnames(mw_admin_stunting)
library(tidyverse)
library(ggplot2)

# need to sort data and take top 5 

top5 = mw_admin_stunting |> arrange(desc(Prb.2SD))
top5
ggplot(data = top5, aes(x = adm2_nm, y = Prb.2SD)) +
  geom_col() + 
  labs(title = "Districts where stunting was highest",
       x = "District", y = "Stunting (%)")





