library(shiny)
library(bslib)
library(leaflet)
# Define UI for random distribution app ----
# Sidebar layout with input and output definitions ----
ui <- page_sidebar(
  
  # App title ----
  title ="NUTRITION DASHBOARD",
  
  # Sidebar panel for inputs ----
  sidebar = sidebar(
    
    # Input: Select the random distribution type ----
    h5("Sidebar inputs")
  ),
  
  # Main panel for displaying outputs ----
  # Output: A tabset that combines three panels ----
  
  navset_card_underline(
    
    # Panel with plot ----
    nav_panel("Overview", 
              layout_columns(
              bslib::value_box("2024 Stunting", "38%"), 
              value_box("2024 Wasting", "2%"),
              value_box("2024 Underweight", "10%"),
              col_widths = c(4, 4, 4)),
              
              
              
              plotOutput("trend_plot"),
              ),
    
    # Panel with summary ----
    
    nav_panel("Geographic Disparities", 
              layout_columns(
              leafletOutput("map"))
              ),
    
    # Panel with table ----
    nav_panel("Table", tableOutput("table"))
  )
  
)