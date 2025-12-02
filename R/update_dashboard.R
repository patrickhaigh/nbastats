library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(stringr)
library(tibble)

if (!dir.exists("figs")) dir.create("figs")

totals_clean <- try(
  read_csv("data/clean/totals_clean_all.csv", show_col_types = FALSE),
  silent = TRUE
)

if (!inherits(totals_clean, "try-error") && nrow(totals_clean) > 0) {
  latest_date <- max(totals_clean$snapshot_date, na.rm = TRUE)

  latest_top10_players <- totals_clean |>
    filter(snapshot_date == latest_date) |>
    arrange(desc(pts)) |>
    slice(1:10) |>
    pull(player)

  top10_history <- totals_clean |>
    filter(player %in% latest_top10_players)

  p <- ggplot(
    top10_history,
    aes(x = snapshot_date, y = pts, color = player, group = player)
  ) +
    geom_line() +
    labs(
      title = "NBA season total points for top 10 scorers",
      subtitle = paste("Updated through", latest_date),
      x = "Date",
      y = "Season total points",
      color = "Player"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16),
      plot.subtitle = element_text(size = 12),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 12),
      legend.position = "bottom"
    )

  ggsave("figs/nba_totals_top10.png", p, width = 9, height = 5, dpi = 150)
}
