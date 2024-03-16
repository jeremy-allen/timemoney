# Time is Money

UPDATE: now a Shiny app!

Use case: you have a price that you want to convert between two currencies, and you want to know the converted price for a given date and the same date 12 months prior.

## Example
**Input:**
```
convert_price(
   price = 350700,
   from = "USD",
   to = "CAD",
   date = "2023-02-10"
)
```
**Output:**
```
We are converting USD to CAD 
On 2023-02-10, 350,700.00USD  is: 469,499.63CAD 
On 2022-02-10, 350,700.00USD was: 446,534.04CAD 
Difference:  22,965.59CAD 
Exchange rate on 2023-02-10: 1.33875 
Exchange rate on 2022-02-10: 1.273265
```
## Requirements
This R function requires the `priceR` and `tidyverse` packages. Use of `priceR` requires a free or paid account at https://exchangerate.host/ and that your account API key is available in your R session as an environment variable.
