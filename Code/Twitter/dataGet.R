#make outh data

library(ROAuth)
setwd('/Users/pagarwal/Desktop/TwitterD')

requestURL = 'https://api.twitter.com/oauth/request_token'
accessURL = 'https://api.twitter.com/oauth/access_token'
authURL = 'https://api.twitter.com/oauth/authorize'
consumerKey = 'Ev1sh2XxP5gHaKrEEpOlFYi3B'
consumerSecret = 'NmUlPoEbl5zrqBv0bJ80NdRwiGCrRUE4hQ2pWXlMA9KlpXvK8P'
my_oauth = OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                            requestURL = requestURL, accessURL = accessURL, authURL = authURL)
my_oauth$handshake(cainfo = system.file('CurlSSL', 'cacert.pem', package = 'RCurl'))
save(my_oauth, file = 'data/my_oauth.RData')

#make state data

library(maps)
library(maptools)
gpclibPermit()
setwd('/Users/pagarwal/Desktop/TwitterD')

states = map('state', fill=TRUE, col='transparent', plot = F)
ids = sapply(strsplit(states$names, ':'), function(x) x[1])
states_sp = map2SpatialPolygons(states, IDs = ids,
                                proj4string = CRS('+proj=longlat +datum=WGS84'))

save(states_sp, file = 'data/states_sp.RData')


#make country and continet data
country_continet <- read.csv("Countries-Continents-csv.csv", header = T)
save(country_continet, file = 'data/country_continet.RData')

#make country zone data
save(country_zone, file = 'country_zone.RData')
