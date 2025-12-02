library(rvest)
library(dplyr)
library(readr)
library(lubridate)

dir.create("data/raw", showWarnings = FALSE)

today <- Sys.Date()

url_totals <- "https://www.basketball-reference.com/leagues/NBA_2026_totals.html"

page_totals <- read_html(url_totals)

tables_totals <- page_totals |> html_table()

totals_raw <- tables_totals[[1]]

totals_raw <- totals_raw |>
  mutate(snapshot_date = today)

write_csv(
  totals_raw,
  file.path("data", "raw", paste0("totals_raw_", today, ".csv"))
)
