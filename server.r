
# Define server logic required to plot batted ball for each player
shinyServer(function(input, output,session) {
  # Compute the forumla text in a reactive function since it is 

    formulaText <- reactive(function() {
    paste(input$batter)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText(function() {
    formulaText()
  })
  
  selectedData <- reactive({
    km_df<-data.table(na.omit(batting_data_over_100[batter_name %in% as.character(input$batter)]))
    m<-as.matrix(cbind(km_df$hitx,km_df$hity), ncol=2)
    kmeans_baseball<-kmeans(m, 4)
    km_df[,cluster:=kmeans_baseball$cluster]
  })
  datasetInput<- reactive({
    switch(input$year)
  })
  
  clusters <- reactive({
    km_df<-data.table(na.omit(batting_data_over_100[batter_name %in% as.character(input$batter)]))
    m<-as.matrix(cbind(km_df$hitx,km_df$hity), ncol=2)
    kmeans_baseball<-kmeans(m, 4)
  })
  
  output$sprayplot <-  renderPlot({
    #combine the clustered data to a main df adn plot it
    p0<-ggplot(data=selectedData(), aes(hitx,hity))
    p1<-p0+geom_point(aes(colour=cluster)) + geom_point(data=as.data.table(clusters()$centers), aes(x=V1,y=V2), size=65, alpha=.3)
    p2<-p1+coord_equal()
    p3<-p2+geom_path(aes(x=x,y=y), data=bases)
    p4<-p3+guides(col=guide_legend(ncol=2))
    p4+geom_segment(x=0,xend=300,y=0,yend=300)+geom_segment(x=0,xend=-300,y=0,yend=300)
  })
  output$summary <- renderPrint({
   print(input$batter)
   print(input$year)
   print(clusters()$centers)
  })
  
  
})