library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Batters"),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    selectizeInput(
      'batter', 'Batters',
      selected = 'Bryce Harper',
      choices = batters
    )
    #selectInput("batter", "Batter:",
     #           list(batters=batters)),
    #selectInput("year", "Year:",
    #            list(years=years)),
   # selectizeInput(
  #    'year', 'Years', choices = list(years=years), multiple = TRUE
  #  )
  ),
  
  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    h3(textOutput("Test")),
    plotOutput("sprayplot"),
    verbatimTextOutput("summary")
  )
))