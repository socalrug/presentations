library(shiny)

incrementButton <- function(inputId, value = 0) {
  tagList(
    singleton(tags$head(tags$script(src = "js/increment.js"))),
    tags$button(id = inputId,
                class = "increment btn btn-default",
                type = "button",
                as.character(value))
  )
}

ui <- fluidPage(
  titlePanel("Custom Input Demo"),
  incrementButton("incButton"),
  textOutput("txt")
)


server <- function(input, output) {
  output$txt <- renderText(sprintf("Behold, the count is now: %s", input$incButton))
}

shinyApp(ui = ui, server = server)

