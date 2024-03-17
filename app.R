library(shiny)
library(bslib)
library(priceR)
library(tidyverse)

currencies_table <- priceR::currencies()

currencies <- as.list(currencies_table$code)
names(currencies) <- paste0(currencies_table$description,
                            " - ",
                            currencies_table$code)

source("exchanges.R")

ui <- page_fillable(
  theme = bs_theme(
    bootswatch = "lux"
  ),
  div(
    align = "center",
    span(
      img(src = "galaxy_logo.png", width = "45px",
          style = "padding: 0; margin: 0;"),
      span("Time is Money",
           style = "font-size: 3rem; line-height: 3rem; vertical-align: bottom")
    )
  ),
  h6("a currency converter", align = "center"),
  br(),
  fluidRow(
    column(
      width = 3,
      numericInput(
        inputId = "price",
        label = "Price",
        value = 100000,
        min = 0
      )
    ),
    column(
      width = 3,
      selectInput(
        inputId = 'from',
        label = 'From Currency',
        choices = c(Choose='', currencies),
        selected = "USD",
        selectize=TRUE
      )
    ),
    column(
      width = 3,
      selectInput(
        inputId = 'to',
        label = 'To Currency',
        choices = c(Choose='', currencies),
        selected = "GBP",
        selectize=TRUE
      )
    ),
    column(
      width = 3,
      dateInput(
        inputId = "date",
        label = "Date",
        value = lubridate::today(),
        format = "yyyy-mm-dd",
        startview = "month",
      )
    )
  ),
  br(),
  fluidRow(
    column(
      width = 12,
      div(
        style = "text-align: center;",
        actionButton(
          inputId = "convert",
          label = "Convert"
        )
      )
    )
  ),
  br(),
  fluidRow(
    column(
      width = 12,
      card(
        min_height = 200,
        full_screen = TRUE,
        card_header(
          class = "bg-dark",
          "See, time is money"
        ),
        card_body(
          verbatimTextOutput(
            outputId = "result"
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  output$result <- renderPrint({
    convert_price(
      price = input$price,
      from = input$from,
      to = input$to,
      date = input$date
    )
  }) |> 
    bindEvent(input$convert)
  
}

shinyApp(ui, server)
