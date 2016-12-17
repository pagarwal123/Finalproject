library(shiny)
library(shinyIncubator)
source('b.R')
shinyServer(function(input, output) {
  
  output$pre <- renderText({
    if(input$a!=""){
    result <- calculatePre(input$a)
    if(result == "negative"){
      print("It is a negative statement")
    }
    else if(result == "neutral"){
      print("It is a neutral statement")
    }
    else if(result == "positive"){
      print("It is a positive statement")
    }
    }
  })
})