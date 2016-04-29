
# Define server logic required to plot batted ball for each player
shinyServer(function(input, output) {
  # Compute the forumla text in a reactive function since it is 
  # shared by the output$caption and output$mpgPlot functions
  formulaText <- reactive(function() {
    paste(input$batter)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText(function() {
    formulaText()
  })
  
  # Generate a plot of the requested variable against mpg and only 
  # include outliers if requested
  # ggplot version
  datasetInput <- reactive({
    switch(input$batter)
  })
  datasetInput<- reactive({
    switch(input$year)
  })
  
  output$sprayplot <-  reactivePlot(function() {
    
    
    
    p0<-ggplot(data=batting_data_over_100[batter_name %in% as.character(input$batter)], aes(hitx,hity))+ylim(-10,200)+xlim(-100,100)
    p1<-p0+geom_point(aes(colour=hit_type))
    #p1<-p0+geom_point(aes(shape=hit_type, colour=pitch_type,size=end_speed))
    p2<-p1+coord_equal()
    p3<-p2+geom_path(aes(x=x,y=y), data=bases)
    p4<-p3+guides(col=guide_legend(ncol=2))
    print(p4+geom_segment(x=0,xend=300,y=0,yend=300)+geom_segment(x=0,xend=-300,y=0,yend=300))
    #}
  })
  output$summary <- renderPrint({
    print(input$batter)
    print(input$year)
  })
  
  
})