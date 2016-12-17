library(streamR)
library(sp)
library(maps)
library(mapproj)
library(ggplot2)
library(grid)
library(ROAuth)
library(tm)
library(wordcloud)
library(dplyr)
library(ggmap)
library(stringr)
library(rworldmap)
library(plotrix)
library(sm)
library(syuzhet)
load(file = 'data/my_oauth.RData')
load(file = 'data/pos_words.RData')
load(file = 'data/neg_words.RData')
load(file = 'data/country_continet.RData')
load(file = 'country_zone.RData')

#world data
world_map = map_data('world')
names(world_map)[5] = 'country'


#calculate sentiment score
calculateSentiment = function(txt) {
  words = strsplit(txt, ' +')
  words = unlist(words)
  positiveWords = match(words, pos)
  negativeWords = match(words, neg)
  score = sum(!is.na(positiveWords)) - sum(!is.na(negativeWords))
  return(score)
}


#Analyze sentiments
analyzeSentiments<-function(keyword1text,keyword2text,keyword1entry,keyword2entry){
  
  keyword1text = gsub('[^[:alpha:]]', ' ', keyword1text)
  keyword1text = tolower(keyword1text)
  keyword2text = gsub('[^[:alpha:]]', ' ', keyword2text)
  keyword2text = tolower(keyword2text)
  score1 = sapply(keyword1text, calculateSentiment)
  keyword1score = data.frame(score=score1, text=keyword1text, size=seq(length(score1)))
  score2 = sapply(keyword2text, calculateSentiment)
  keyword2score = data.frame(score=score2, text=keyword2text, size=seq(length(score2)))
  keyword1score$entity = keyword1entry
  keyword2score$entity = keyword2entry
  keywordCombinedScore<-rbind(keyword1score,keyword2score)
  
} 
analyzeSentiments1<-function(keywordText,entityentry){
  
  keywordText = gsub('[^[:alpha:]]', ' ', keywordText)
  keywordText = tolower(keywordText)

  score1 = sapply(keywordText, calculateSentiment)
  keywordScore = data.frame(score=score1, text=keywordText, size=seq(length(score1)))

  keywordScore$entity = entityentry

  keywordScore1<-keywordScore
  
} 

#fetch tweets
getAllTweets = function(searchTerm) {
  
  
  track    <- searchTerm
  print(track)
  print(searchTerm)
  #new tweets after every 10 sec
  tweets = filterStream(file.name = '', track=track,language = 'en', timeout = 10, oauth = my_oauth)
  
 #perform if only following condition of atleast 2 tweets are fertched
  if (length(tweets) > 2) {
    tweets = parseTweets(tweets)
    tweets$continent <- NA
    #get country
    for(i in 1:nrow(tweets)){
      if(is.na(tweets[i,"time_zone"])){
        tweets[i,"country"] <- "United States"
      }
      else{
        if(grepl("US",tweets[i,"time_zone"]) || grepl("Canada",tweets[i,"time_zone"])){
        tweets[i,"country"] <- "United States"
        }
        else{
          for (j in 1:nrow(country_zone)) {
            if(grepl(tweets[i,"time_zone"],country_zone[j,2]) )
              {
                tweets[i,"country"] <- as.character(country_zone[j,3])
              }
          }
          if(is.na(tweets[i,"country"])){
            tweets[i,"country"] <- "United States"
          }
        }
      }
    }
    
    #get continent
    for(m in 1:nrow(tweets)){
      for (n in 1:nrow(country_continet) ) {
        if(grepl(tweets[m,"country"],country_continet[n,2]) ){
          tweets[m,"continent"] <- as.character(country_continet[n,1])
        }
      }
    }

    #clean tweets
    text = gsub('[^[:graph:]]', ' ', as.character(tweets$text))
    text = gsub('^ +', '', text)
    text = gsub(' +$', '', text)
    text = gsub(' +', ' ', text)
    text <- gsub("http://t.co/[a-z,A-Z,0-9]*{8}","",text)
    text <- gsub("https://t.co/[a-z,A-Z,0-9]*{8}","",text)
    text <- gsub("RT @[a-z,A-Z]*: ","",text)
    text <- gsub("#[a-z,A-Z]*","",text)
    text <- gsub("@[a-z,A-Z]*","",text)
    tweets$text = text
    text = gsub('[^[:alpha:]]', ' ', text)
    text = tolower(text)
    
    tweets$sentiment = sapply(text, calculateSentiment)
    #work on timestamps
    tweets$created_at = as.character(tweets$created_at)
    date1 = substr(tweets$created_at, 5, 10)
    date2 = substr(tweets$created_at, nchar(tweets$created_at)-3, nchar(tweets$created_at))
    time = substr(tweets$created_at, 12, 19)
    tweets$ts = paste(date1, date2, time)
    #fetch time ranges
    tweets$ts_r = paste(min(time, na.rm = T), max(time, na.rm = T), sep = '-')
    k <- as.data.frame(unique(tweets$country))
    #fetch lat and lon
    colnames(k) <- "country"
    k$country <- as.character(k$country)
    locations <- geocode(k$country) 
    k <- cbind(k,locations)
    tweets$lon <- k$lon[match(tweets$country,k$country)]
    tweets$lat <- k$lat[match(tweets$country,k$country)]
    tweets <- tweets %>% mutate(sentichar = ifelse(sentiment > 0, "Positive", ifelse(sentiment < 0 , "Negative", "Neutral")))
    tweets = subset(tweets, select = c(text, sentiment, ts, ts_r,country,continent,lon,lat,sentichar))
    
    return(tweets) 
  }
  else {
    return(data.frame(text = character(), sentiment = numeric(), ts = character(), ts_r = character(), country = character(), continent = character()))
  }
}
#trend plot
graph_Trends_1 = function(dat_all, title,a) {
  dat_all$seq = match(dat_all$ts_r, sort(unique(dat_all$ts_r)))
  
  #calculate % of positive sentiment for continents
  sentiment_prop = dat_all %>%
    group_by(continent, seq) %>%
    summarise(sentiment_prc = totalSentiment(sentiment))
  
  trend_plot = ggplot(sentiment_prop, aes(x = seq, y = sentiment_prc, col = continent)) + 
    geom_point() + geom_line() +
    guides(col = guide_legend(title = NULL)) +
    scale_y_continuous(breaks = seq(0, 1, .25),
                       labels = c('Negative', '', 'Neutral', '', 'Positive')) +
    theme(legend.position = 'bottom', axis.text.x = element_blank(),
          panel.grid = element_blank(), panel.border = element_blank(),
          axis.ticks = element_blank(),
          panel.background = element_blank(), plot.background = element_blank(),
          legend.background = element_blank()) +
    xlab('Time Interval') + ylab('Sentiment') +
    ggtitle(paste0(title,a))
  
  return(trend_plot)
}

graphTrends_1 = function(dat_all, title,a) {

  dat_all$seq = match(dat_all$ts_r, sort(unique(dat_all$ts_r)))
  dat_all = arrange(dat_all, seq)
  
  #calculate % of positive sentiment
  sentiment_prop = dat_all %>%
    group_by(continent, seq) %>%
    summarise(sentiment_prc = totalSentiment(sentiment))
  
  trend_plot = ggplot(sentiment_prop, aes(x = seq, y = sentiment_prc, col = continent)) + 
    geom_point() + stat_smooth(method = 'loess', se = F) +
    guides(col = guide_legend(title = NULL)) +
    scale_y_continuous(breaks = seq(0, 1, .25),
                       labels = c('Negative', '', 'Neutral', '', 'Positive')) +
    theme(legend.position = 'bottom', axis.text.x = element_blank(),
          panel.grid = element_blank(), panel.border = element_blank(),
          axis.ticks = element_blank(),
          panel.background = element_blank(), plot.background = element_blank(),
          legend.background = element_blank()) +
    xlab('Time Interval') + ylab('Sentiment') +
    ggtitle(paste0(title,a))
  
  return(trend_plot)
}
#ratio of positive and negative tweets
totalSentiment = function(x) {
  totalPositve = sum(x[which(x > 0)])
  absoluteSum = sum(abs(x))
  return(totalPositve / absoluteSum)
  
}

wordcloudentity<-function(text,a)
{ 
  text = gsub('http', ' ', text)
  text = gsub('https',' ',text)
  tweetCorpus<-Corpus(VectorSource(text))
  tweetTDM<-TermDocumentMatrix(tweetCorpus,control=list(removePunctuation=TRUE,
                                                        stopwords=c(stopwords('english')),
                                                        removeNumbers=TRUE,tolower=TRUE))
  tdMatrix <- as.matrix(tweetTDM)
  sortedMatrix<-sort(rowSums(tdMatrix),decreasing=TRUE) 
  cloudFrame<-data.frame(word=names(sortedMatrix),freq=sortedMatrix)
  wcloudentity<-wordcloud(cloudFrame$word,cloudFrame$freq,max.words=50, colors=brewer.pal(8,"Dark2"),scale=c(8,1), random.order=TRUE)
  print(wcloudentity)
}

plotworldmap = function(combinedData1, title,a){
  worldMap <- map_data("world")
  map_world <- ggplot(worldMap)
  map_world <- map_world + borders("world", colour="gray50", fill="gray50")
  map_world <- map_world + geom_path(aes(x = long, y = lat, group = group),  # Draw map
                         colour = gray(2/3), lwd = 1/3) +ggtitle(paste0("sentiment for ",a))
  map_world <- map_world + geom_point(data = combinedData1,  # Add points indicating users
                          aes(x = lon, y = lat, colour = factor(sentichar)))
  map_world <- map_world + coord_equal() 
  map_world <- map_world + theme_minimal() 
  print(map_world)
}

plotsentiment = function(combinedData, title, a){
  as <- combinedData
  mySentiment <- get_nrc_sentiment(as$text)
  as <- cbind(as, mySentiment)
  sentimentTotals <- data.frame(colSums(as[,c(10:17)]))
  names(sentimentTotals) <- "count"
  sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
  rownames(sentimentTotals) <- NULL
  ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
    geom_bar(aes(fill = sentiment), stat = "identity") +
    theme(legend.position = "none") +
    xlab("Sentiment") + ylab("Total Count") + ggtitle(paste0("Total Sentiment Score for All Tweets of ",a))
}

