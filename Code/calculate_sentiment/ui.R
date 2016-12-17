library(shiny)
library(shinyIncubator)
shinyUI(bootstrapPage(
  
  fluidPage(
    titlePanel("Calculate sentiment"),
    sidebarPanel(
    textInput("a", "Enter input statement"),
    submitButton("Submit")
    ),
    mainPanel(
      h1(textOutput("pre"))
    )
  )
  
))