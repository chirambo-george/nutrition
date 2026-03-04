library(shiny)
library(bslib)
library(leaflet)
# Define UI for random distribution app ----
# Sidebar layout with input and output definitions ----
ui <- page_navbar(
  
  # App title ----
  title ="NUTRITION DASHBOARD",
  

  
  # Main panel for displaying outputs ----
  # Output: A tabset that combines three panels ----
  
  navset_card_underline(
    
    # Panel with plot ----
    nav_panel("Overview", 
              layout_columns(
              bslib::value_box("2024 Stunting", "38%",
                               p(
                                 bsicons::bs_icon("arrow-up", size = "1.5em"), 
                                 "from 37% (2015-16 MDHS)",
                                 style = "font-size: 0.7em; color: red; margin-top: 8px;"
                               )), 
              value_box("2024 Wasting", "2%",
                        p(
                          bsicons::bs_icon("arrow-down", size = "1.5em"), 
                          "from 3% (2015-16 MDHS)",
                          style = "font-size: 0.7em; color: #28a745; margin-top: 8px;",
                          
                        )),
              value_box(
                title = "2024 Overweight", 
                value = "6%",
                p(
                  bsicons::bs_icon("arrow-up", size = "1.5em"), 
                  "from 5% (2015-16 MDHS)",
                  style = "font-size: 0.7em; color: red; margin-top: 8px;"
                )
              ),
              
              col_widths = c(4, 4, 4)),
              
              
              layout_columns(
              plotOutput("trend_plot"),
              plotOutput("top5_stunting")
              ), 
              
              ),
    
    # Panel with summary ----
    
  
    nav_panel("Geographic Disparities", 
                    # layout_columns(
                    # leafletOutput("map_stunting"),
                    # leafletOutput("map_wasting"),
                    # leafletOutput("map_overweight"),
                    # col_widths = 4, ),
              
              accordion(
                  open = c("geographic disparities", "About"),
                accordion_panel(
                  "maps",
                  
                  layout_columns(
                    leafletOutput("map_stunting"),
                    leafletOutput("map_wasting"),
                    leafletOutput("map_overweight")),
                ),
                
                # graph under the maps for more vizzes
                
                accordion_panel(
                  "bar charts",
                  plotOutput("bar_chart")
                )
              )
              
              ),
    
    # Panel with table ----
    nav_panel("Table", tableOutput("table"))
  )
  
)