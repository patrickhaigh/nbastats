library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(lubridate)
library(purrr)
library(tibble)

if (!dir.exists("data")) dir.create("data")
if (!dir.exists("data/clean")) dir.create("data/clean")

clean_player_names <- function(df, player_col) {
  df |>
    mutate(
      {{ player_col }} := str_squish({{ player_col }}),
      {{ player_col }} := str_to_upper({{ player_col }})
    )
}

read_raw_totals <- function() {
  files <- list.files(
    "data/raw",
    pattern = "^totals_raw_.*\\.csv$",
    full.names = TRUE
  )

  if (length(files) == 0) {
    return(tibble())
  }

  files |>
    map_dfr(read_csv, show_col_types = FALSE)
}

totals_raw_all <- read_raw_totals()

if (nrow(totals_raw_all) == 0) {
  totals_clean <- tibble()
} else {
  totals_clean <- totals_raw_all |>
    clean_names() |>
    filter(rk != "Rk") |>
    clean_player_names(player) |>
    mutate(
      snapshot_date = as_date(snapshot_date)
    )

  num_cols <- c(
    "rk", "age", "g", "gs", "mp", "fg", "fga", "fg_percent",
    "x3p", "x3pa", "x3p_percent", "x2p", "x2pa", "x2p_percent",
    "efg_percent", "ft", "fta", "ft_percent", "orb", "drb", "trb",
    "ast", "stl", "blk", "tov", "pf", "pts"
  )

  totals_clean <- totals_clean |>
    mutate(across(any_of(num_cols), as.numeric))
}

write_csv(totals_clean, "data/clean/totals_clean_all.csv")
