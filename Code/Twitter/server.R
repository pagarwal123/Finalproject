library(shiny)
library(shinyIncubator)
source('Functions.R')

#create name for temp file created on the fly
keyword1_data_entire = paste0('data/keyword1_data_', format(Sys.time(), '%Y-%m-%d_%H-%M-%S'), '.RData')
keyword2_data_entire = paste0('data/keyword2_data_', format(Sys.time(), '%Y-%m-%d_%H-%M-%S'), '.RData')


shinyServer(function(input, output, session) {
  #retrieves new tweets every 10 second
  autoInvalidate = reactiveTimer(11000, session)
  
  getKeyword1 = reactive({
    if(input$actb>0 && input$actbutton!=1){ 
    autoInvalidate()
      getAllTweets(input$keyword1)
    }
  })
  getKeyword2 = reactive({
    if(input$actb>0 && input$actbutton!=1){ 
    autoInvalidate()
    getAllTweets(input$keyword2)
    }
  })
  
  keywordCombinedScore = reactive({
    if(input$actb>0 ){ 
        keywordCombinedScore<-analyzeSentiments(getKeyword1()$text,getKeyword2()$text,input$keyword1,input$keyword2)}
})
  
  keywordScore1 = reactive({
    if(input$actb>0 ){ 
      keywordScore1<-analyzeSentiments1(getKeyword1()$text,input$keyword1)}
  })
  
  keywordScore2 = reactive({
    if(input$actb>0 ){ 
      keywordScore2<-analyzeSentiments1(getKeyword2()$text,input$keyword2)}
  })
  
  output$currentTime <- renderText({
    invalidateLater(1000,session)
    paste("The current time is :", Sys.time())
  })
  
  observe({
    data1 = getKeyword1()
    data2 = getKeyword2()
    
    #combine data from start for keyword
    if (file.exists(file = keyword1_data_entire)) {
      load(file = keyword1_data_entire)
      combinedData1 = rbind(combinedData1, data1)
    }
    else {
      combinedData1 = data1
    }
    save(combinedData1, file = keyword1_data_entire)
    #combine data from start for keyword
    if (file.exists(file = keyword2_data_entire)) {
      load(file = keyword2_data_entire)
      combinedData2 = rbind(combinedData2, data2)
    }
    else {
      combinedData2 = data2
    }
    save(combinedData2, file = keyword2_data_entire)
  
    #sample positive and negative tweet
    countData1 = sum(!is.na(data1$text))
    if (countData1 > 0) {
      timestampMin1 = min(data1$ts, na.rm = T)
      timestampMax1 = max(data1$ts, na.rm = T)
      positiveWord1 = ifelse(max(data1$sentiment, na.rm = T) > 0,
                          sample(data1$text[which(data1$sentiment > 0)], 1),
                          '')
      negativeWord1 = ifelse(min(data1$sentiment, na.rm = T) < 0,
                          sample(data1$text[which(data1$sentiment < 0)], 1),
                          '')
    }
    
    countData2 = sum(!is.na(data2$text))
    if (countData2 > 0) {
      timestampMin2 = min(data2$ts, na.rm = T)
      timestampMax2 = max(data2$ts, na.rm = T)
      
      #sample positive and negative tweets
      positiveWord2 = ifelse(max(data2$sentiment, na.rm = T) > 0,
                           sample(data2$text[which(data2$sentiment > 0)], 1),
                           '')
      negativeWord2 = ifelse(min(data2$sentiment, na.rm = T) < 0,
                           sample(data2$text[which(data2$sentiment < 0)], 1),
                           '')
    }
    
    #combined tweets 
    countDataEntire1 = sum(!is.na(combinedData1$text))
    if (countDataEntire1 > 0) {
      positivecount1 = length(combinedData1$text[which(combinedData1$sentiment > 0)])
      neutralcount1 = length(combinedData1$text[which(combinedData1$sentiment == 0)])
      negativecount1 = length(combinedData1$text[which(combinedData1$sentiment < 0)])
      timestampMinFull1 = min(combinedData1$ts, na.rm = T)
      timestampMaxFull1 = max(combinedData1$ts, na.rm = T)
      intervals1 = length(unique(combinedData1$ts_r))
    }
    
    countDataEntire2 = sum(!is.na(combinedData2$text))
    if (countDataEntire2 > 0) {
      positivecount2 = length(combinedData2$text[which(combinedData2$sentiment > 0)])
      neutralcount2 = length(combinedData2$text[which(combinedData2$sentiment == 0)])
      negativecount2 = length(combinedData2$text[which(combinedData2$sentiment < 0)])
      timestampMinFull2 = min(combinedData2$ts, na.rm = T)
      timestampMaxFull2 = max(combinedData2$ts, na.rm = T)
      intervals2 = length(unique(combinedData2$ts_r))
    }
    
    #display sample tweets
    output$tweets_display_1 = renderUI({
      if (countData1 > 0) {
        positivetweets_display_1 = ifelse(positiveWord1 != '',
                       paste('positive tweet:', positiveWord1),
                       'No one tweeted positive for 10 secs')
        negativetweets_display_1 = ifelse(negativeWord1 != '',
                       paste('negative tweet:', negativeWord1),
                       'No one tweeted negative for 10 secs')
        HTML('<h5>',input$keyword1,'<br>', positivetweets_display_1, '<br>', negativetweets_display_1, '<h5>')
      }
      else {
        h1 = 'No one tweeted for 10 secs'
        HTML('<h5>', h1, '<h5>')
      }
    })
    
    output$tweets_display_2 = renderUI({
      if (countData2 > 0) {
        positivetweets_display_2 = ifelse(positiveWord2 != '',
                        paste('positive tweet:', positiveWord2),
                        'No one tweeted positive for 10 secs')
        negativetweets_display_2 = ifelse(negativeWord2 != '',
                        paste('negative tweet:', negativeWord2),
                        'No one tweeted negative for 10 secs')
        HTML('<h5>',input$keyword2, '<br>' ,positivetweets_display_2, '<br>', negativetweets_display_2, '<h5>')
      }
      else {
        h2 = 'No one tweeted for 10 seconds.'
        HTML('<h5>', h2, '<h5>')
      }
    })
    
    output$boxPlot = renderPlot({
      if(countData1 > 0 && countData2 >0){
        cutoff <- data.frame(yintercept=0, cutoff=factor(0))
        boxPlot<-ggplot(keywordCombinedScore(),aes(x=size,y=score))+
          facet_grid(entity ~ .)+
          geom_point(color = "black",size = 2, alpha = 1/2)+
          geom_smooth(method = "loess",se=FALSE,col='red',size=1.5, alpha = 0.7)+
          geom_hline(aes(yintercept=yintercept, linetype=cutoff), data=cutoff)+
          xlab('Tweet number')+
          ylab('Sentiment Score')+
          theme_bw()
        print(boxPlot)
        
      }
      else if(countData1 >0 ){
        cutoff <- data.frame(yintercept=0, cutoff=factor(0))
        boxPlot<-ggplot(keywordScore1(),aes(x=size,y=score))+
          facet_grid(entity ~ .)+
          geom_point(color = "black",size = 2, alpha = 1/2)+
          geom_smooth(method = "loess",se=FALSE,col='red',size=1.5, alpha = 0.7)+
          geom_hline(aes(yintercept=yintercept, linetype=cutoff), data=cutoff)+
          xlab('Tweet number')+
          ylab('Sentiment Score')+
          theme_bw()
        print(boxPlot)
      }
      else if(countData2 > 0){
        cutoff <- data.frame(yintercept=0, cutoff=factor(0))
        boxPlot<-ggplot(keywordScore2(),aes(x=size,y=score))+
          facet_grid(entity ~ .)+
          geom_point(color = "black",size = 2, alpha = 1/2)+
          geom_smooth(method = "loess",se=FALSE,col='red',size=1.5, alpha = 0.7)+
          geom_hline(aes(yintercept=yintercept, linetype=cutoff), data=cutoff)+
          xlab('Tweet number')+
          ylab('Sentiment Score')+
          theme_bw()
        print(boxPlot)
      }
    })
    
    #output trend plot
    output$graphTrends1 = renderPlot({
      if (countDataEntire1 > 0 && intervals1 > 8) {
        print(graphTrends_1(combinedData1, 'Trends of positive and negative sentiments:combined ', input$keyword1))
      }
      else if (countDataEntire1 > 0) {
        print(graph_Trends_1(combinedData1, 'Trends of positive and negative sentiments:combined ', input$keyword1))
      }
    }, bg = 'transparent')
    
    
    #output trend plot
    output$graphTrends2 = renderPlot({
      if (countDataEntire2 > 0 && intervals2 > 8) {
        #only use loess-smoothing when more than 8 data points are collected (determined through trial and error)
        print(graphTrends_1(combinedData2, 'Trends of positive and negative sentiments:combined ', input$keyword2))
      }
      else if (countDataEntire2 > 0) {
        print(graph_Trends_1(combinedData2, 'Trends of positive and negative sentiments:combined ', input$keyword2))
      }
    }, bg = 'transparent')
    
    output$wordcloud1 = renderPlot({
      if(countDataEntire1>0){
        print(wordcloudentity(combinedData1$text,input$keyword1))
      }
    })
    output$wordcloud2 = renderPlot({
      if(countDataEntire2>0){
        
        print(wordcloudentity(combinedData2$text,input$keyword2))
      }
    })
    # output$currentTime <- renderText({ #Here I will show the current time
    #   paste("Current time is: ",Sys.time())})
    # 
    output$firstdistPlot <- renderPlot({
      
      if(countDataEntire1>0){
      results1 = data.frame(tweets = c("Positive", "Negative", "Neutral"), numbers = c(positivecount1,negativecount1,neutralcount1))
      barplot(results1$numbers, names = results1$tweets, xlab = "Sentiment", ylab = "Counts", col = c("Green","Red","Blue"), main = paste0(" % Plot for ",input$keyword1))
      }
    })
    output$seconddistPlot <- renderPlot({
      
      if(countDataEntire2>0){
        results2 = data.frame(tweets = c("Positive", "Negative", "Neutral"), numbers = c(positivecount2,negativecount2,neutralcount2))
        barplot(results2$numbers, names = results2$tweets, xlab = "Sentiment", ylab = "Counts", col = c("Green","Red","Blue"), main = paste0(" % Plot for ",input$keyword2))
      }
    })
    
    output$firstworldmap = renderPlot({
      if (countDataEntire1 > 0) {
        print(plotworldmap(combinedData1, 'sentiments for ', input$keyword1))
      }
    }, bg = 'transparent', width = 600, height = 450)
    
    
    output$secondworldmap = renderPlot({
      if (countDataEntire2 > 0) {
        print(plotworldmap(combinedData2, 'sentiment for ', input$keyword2))
      }
    }, bg = 'transparent', width = 600, height = 450)
    
    output$firstpiePlot <- renderPlot({
      
      if(countDataEntire1>0){
        results1 = data.frame(tweets = c("Positive", "Negative", "Neutral"), numbers = c(positivecount1,negativecount1,neutralcount1))
        pct1 <- round(results1$numbers/sum(results1$numbers)*100)
        label1 <- paste(results1$tweets,pct1)
        label1 <- paste(label1, "%", sep = "")
        pie3D(results1$numbers,labels=label1,explode=0.1,col = c("Green","Red","Blue"), main= paste0("Pie Chart of percentage sentiments ",""))
      }
    })
    output$secondpiePlot <- renderPlot({
      
      if(countDataEntire2>0){
        results2 = data.frame(tweets = c("Positive", "Negative", "Neutral"), numbers = c(positivecount2,negativecount2,neutralcount2))
        pct2 <- round(results2$numbers/sum(results2$numbers)*100)
        label2 <- paste(results2$tweets,pct2)
        label2 <- paste(label2, "%", sep = "")
        pie3D(results2$numbers,labels=label2,explode=0.1,col = c("Green","Red","Blue"), main= paste0("Pie Chart of percentage sentiments ",input$keyword2))
        
      }
    })
    
    output$kerneldensityplot <- renderPlot({
      if(countDataEntire2>0 && countDataEntire1>0){
        d1 <- density(combinedData1$sentiment)
        d2 <- density(combinedData2$sentiment)
        plot(range(d1$x, d2$x), range(d1$y, d2$y), type = "n", xlab = "sentiment",
             ylab = "Density")
        lines(d1, col = "red")
        lines(d2, col = "blue")
        title(main= paste0("Sentiment comparison","\n",paste0("Red = ",input$keyword1),"\n",paste0("Blue = ",input$keyword2)))
        
      }
    })
    
    output$sentimentdistr1 <- renderPlot({
      if(countDataEntire1>0){
        print(plotsentiment(combinedData1, 'distrbuted sentiments for ', input$keyword1))
      }
    })
    output$sentimentdistr2 <- renderPlot({
      if(countDataEntire2>0){
        print(plotsentiment(combinedData2, 'distrbuted sentiments for ', input$keyword2))
      }
    })
  })
})


