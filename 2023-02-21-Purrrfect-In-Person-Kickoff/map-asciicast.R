library(jsonlite)
library(purrr)

lego_sets <- read_json("lego_sets.json")

slow_name <- function(x) {
  Sys.sleep(0.1)
  x$name[[1]]
}

lego_names <- map(lego_sets, slow_name, .progress = TRUE)
