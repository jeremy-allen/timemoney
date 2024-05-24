library(shiny)
library(bslib)
library(thematic)
library(priceR)
library(tidyverse)

currencies_table <- priceR::currencies()

currencies <- as.list(currencies_table$code)
names(currencies) <- paste0(currencies_table$description,
                            " - ",
                            currencies_table$code)

source("exchanges.R")

# Enable thematic
thematic::thematic_shiny(font = "auto")

# Change ggplot2's default "gray" theme
theme_set(theme_minimal(base_size = 16))

ui <- page_fillable(
  theme = bs_theme(
    bootswatch = "flatly",
    base_font = font_google("Lora"),
    code_font = font_google("JetBrains Mono")
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
          class = "bg-primary",
          inputId = "convert",
          label = "Convert"
        )
      )
    )
  ),
  br(),
  fluidRow(
    column(
      width = 5,
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
    ),
    column(
      width = 7,
      card(
        min_height = 200,
        full_screen = TRUE,
        card_header(
          class = "bg-dark",
          "Exchange Rate"
        ),
        card_body(
          plotOutput(
            outputId = "plot"
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
  
  output$plot <- renderPlot({
    
    start_date <- input$date - lubridate::years(2)
    year_before <- input$date - lubridate::years(1)
    
    dat <- historical_exchange_rates(
      from = input$from,
      to = input$to,
      start_date = start_date,
      end_date = input$date
    )
    
    dat <- dat |> 
      rename(rate = names(dat)[[2]]) |> 
      mutate(date = as.Date(date))

    points <- rbind(
      head(dat, 1),
      dat |> filter(date == as.Date(year_before)),
      tail(dat, 1)
    )
    
    dat |>
      ggplot(aes(x = date, y = rate)) +
      geom_line(linewidth = .8, alpha = .6, color = "#18bc9c") +
      geom_point(data = points,
                 aes(x = date, y = rate),
                 size = 3) +
      geom_label(data = points,
                 aes(x = date, y = rate, label = date),
                 hjust = 0, vjust = 0) +
      scale_x_date(date_labels = "%b %Y", date_breaks = "4 months",
                   expand = c(.18,0.1)) +
      labs(
        title = paste0("The ", input$to, " Exchange Rate "),
        subtitle = paste0("From ", start_date, " to ", input$date)
      )
    
  }) |> 
    bindEvent(input$convert)
  
}

shinyApp(ui, server)
