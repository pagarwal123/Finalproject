library(shiny)
library(shinyIncubator)

shinyUI(fluidPage(theme='bootstrap.min.css',
                  tags$style(type='text/css',
                             'label {font-size: 12px;}',
                             '.recalculating {opacity: 1.0;}'
                              ),

                  headerPanel("Live twitter sentiment analysis"),
                  textOutput("currentTime"),
                  fluidRow(
                    column(3,
                           wellPanel(
                             textInput("keyword1", "keyword 1: "),
                             textInput ("keyword2","keyword 2: "),
                             actionButton(inputId='actb',icon =icon("twitter"), label="Start"),
                             actionButton(inputId='actbutton',icon =icon("twitter"), label="Stop")
                             
                           )
                           # wellPanel(
                           #   textOutput("currentTime")
                           # )
                          ),
                    column(9,
                           wellPanel(
                           
                             p(htmlOutput('tweets_display_1')),
                             p(htmlOutput('tweets_display_2')),
                              tabsetPanel(
                                tabPanel(
                                  "Trend of sentiments:positive and negative for every 10 secs", plotOutput("boxPlot")
                                  
                                ),
                                tabPanel(
                                  "Trend of sentiments:positive and negative", plotOutput("graphTrends1"),plotOutput("graphTrends2")
                                  
                                ),
                                tabPanel(
                                  "wordcloud",
                                  plotOutput("wordcloud1"),
                                  plotOutput("wordcloud2")
                                ),
                                
                                tabPanel(
                                  "Barplot and Pie chart", plotOutput("firstdistPlot"),
                                  plotOutput("firstpiePlot"),
                                  plotOutput("seconddistPlot"),
                                  plotOutput("secondpiePlot")
                                  
                                ),
                                
                                tabPanel(
                                  "Map", plotOutput("firstworldmap"),plotOutput("secondworldmap")
                                  
                                ),
                                tabPanel(
                                  "Kernel Density plot", plotOutput("kerneldensityplot")
                                ),
                                tabPanel(
                                  "Twitter sentiments distribution",plotOutput("sentimentdistr1"),plotOutput("sentimentdistr2")
                                )
                              )
                    )
                  )
                  )
)
)