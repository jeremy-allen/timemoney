convert_price <- function(price, from, to, date = lubridate::today()){
  
  date <- ymd(date)
  is_today <- date == lubridate::today()
  
  year_before <- date - lubridate::years(1)
  
  if(is_today){
    er_date <- exchange_rate_latest(from) |> 
      filter(currency == to) |>
      pull(2)
  } else {
    er_date <- historical_exchange_rates(
      from = from,
      to = to,
      start_date = date,
      end_date = date) |> 
      pull(2)
  }
  
  er_year_before <- historical_exchange_rates(
    from = from,
    to = to,
    start_date = year_before,
    end_date = year_before) |> 
    pull(2)
  
  price_date <- convert_currencies(
    price_start = price,
    from = from,
    to = to,
    date = date,
    floor_unit = "day")
  
  price_year_before <- convert_currencies(
    price_start = price,
    from = from,
    to = to,
    date = year_before,
    floor_unit = "day")
  
  my_diff_num <- (price_date - price_year_before)
  
  my_diff_char <- my_diff_num |> 
    formatC(digits = 2, format = "f", big.mark = ",")
  
  direction <- if_else(my_diff_num > 0, "more", "less")
  
  cat(
  "Converting", from, "to", to, "\n", "On", paste0(as.character(year_before),
                                                   ","),
  paste0(formatC(price, digits = 2, format = "f", big.mark = ","), " ", from),
  "was:",
  paste0(formatC(price_year_before, digits = 2, format = "f", big.mark = ","),
  " ", to), "\n", "On", paste0(as.character(date), ","),
  paste0(formatC(price, digits = 2, format = "f", big.mark = ","), " ", from),
  " is:",
  paste0(formatC(price_date, digits = 2, format = "f", big.mark = ","), " ", to),
  "\n", "Difference: ", my_diff_char, to, "\n",
  "Exchange rate on", paste0(as.character(year_before), ":"), er_year_before,
  "\n", "Exchange rate on", paste0(as.character(date), ":"), er_date,
  "\n\n", "Assuming your price has remained the same,\nyour buyer will spend",
  my_diff_char, direction, "than\nthey did a year prior for the same product.\n"
  )
  
}
