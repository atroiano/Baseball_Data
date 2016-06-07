library(shiny)

# Define UI for miles per gallon application
shinyUI(fluidPage(
  title="Batted Ball Clustering",
    sidebarPanel(
      selectizeInput(
        'batter', 'Batters',
        selected = 'Bryce Harper',
        choices = batters
      )
    ),
    mainPanel(
      plotOutput("sprayplot",height = 750, width = 750),
      verbatimTextOutput("summary")
    )
  )
)