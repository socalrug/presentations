library(shiny)

renderBlinkingText <- function(expr, env=parent.frame(), quoted=FALSE) {
  exprToFunction(expr, env, quoted)
}

blinkingTextOutput <- function(inputId, interval = 300) {
  tagList(
    singleton(tags$head(tags$script(src = "js/blink.js"))),
    tags$span(
      id = inputId, 
      class = "blink",
      `data-interval` = interval,
      `data-input-id` = inputId
    )
  )
}

ui <- fluidPage(
  titlePanel("Custom Output Demo"),
  blinkingTextOutput("blink")
)


server <- function(input, output) {
  output$blink <- renderBlinkingText("~~ heyo, party time! ~~")
}

shinyApp(ui = ui, server = server)

