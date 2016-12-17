#install.packages("RCurl")
#install.packages("bitops")
#install.packages("rjson")
library(RCurl)
library(bitops)
library(rjson)
library(streamR)
library(sp)
#library(maps)
#library(mapproj)
#library(ggplot2)
library(grid)
library(ROAuth)
library(dplyr)

load(file = 'pos_words.RData')
load(file = 'neg_words.RData')
load(file = 'states_sp.RData')
load(file = 'tz.RData')


#Static data

library(twitteR)
consumerKey <- "Ev1sh2XxP5gHaKrEEpOlFYi3B"
consumerSecret <- "NmUlPoEbl5zrqBv0bJ80NdRwiGCrRUE4hQ2pWXlMA9KlpXvK8P"
oauth_token <- "806316172996214784-tCXVHP6InzRo3vhfLck2Z5eH3dvKLTw"
oauth_token_secret <- "Oc64vL7zmLFpYzLwakfExfJQTytCi4M65Jrfmd9hUbSBq"

setup_twitter_oauth(consumerKey, consumerSecret, oauth_token, oauth_token_secret)      #â€œUsing direct authenticationâ€?

tweets1 <- searchTwitter('#iPhone',lang="en",n=10000,since='2016-12-04',until = '2016-12-10')
tweets2 <- searchTwitter('#iPad',lang="en",n=10000,since='2016-12-04',until = '2016-12-10')

tweets_df1 <- twListToDF(tweets1)
tweets_df2 <- twListToDF(tweets2)

#write.csv(tweets_df1, "iPhoneFull.csv")
#write.csv(tweets_df2, "iPadFull.csv")

#clean tweets
text = gsub('[^[:graph:]]', ' ', as.character(tweets_df2$text))
text = gsub('^ +', '', text)
text = gsub(' +$', '', text)
text = gsub(' +', ' ', text)
tweets_df2$text = text

#calculate sentiment function
get_sentiment = function(txt) {
  words = strsplit(txt, ' +')
  words = unlist(words)
  
  pos_matches = match(words, pos)
  neg_matches = match(words, neg)
  
  #count all the mapped positive and negative words and subtract the latter from the former
  score = sum(!is.na(pos_matches)) - sum(!is.na(neg_matches))
  return(score)
}

#estimate sentiment of the tweets
text = gsub('[^[:alpha:]]', ' ', text)
text = tolower(text)

tweets_df2$sentiment = sapply(text, get_sentiment)

#tweets_df1 <- select(tweets_df1, -score)
tweets_df2 <- tweets_df2 %>% mutate(score = ifelse(sentiment > 2, 4, ifelse(sentiment < -2, 0, 2)))

iphone <- select(tweets_df1, text, score)
ipad <- select(tweets_df2, text, sentiment, score)
write.csv(iphone, "iphone.csv")
write.csv(ipad, "ipad1.csv")
