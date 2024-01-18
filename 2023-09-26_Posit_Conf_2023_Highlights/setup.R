hexes <- function(..., size = 64) {
  x <- c(...)
  x <- sort(unique(x), decreasing = TRUE)
  right <- (seq_along(x) - 1) * size
  
  res <- glue::glue(
    '![](hexes/<x>.png){.absolute top=-20 right=<right> width="<size>" height="<size * 1.16>"}',
    .open = "<", .close = ">"
  )
  
  paste0(res, collapse = " ")
}

hexes_svg <- function(..., size = 64) {
  x <- c(...)
  x <- sort(unique(x), decreasing = TRUE)
  right <- (seq_along(x) - 1) * size
  
  res <- glue::glue(
    '![](hexes/<x>.svg){.absolute top=-20 right=<right> width="<size>" height="<size * 1.16>"}',
    .open = "<", .close = ">"
  )
  
  paste0(res, collapse = " ")
}

hexes_duckdb <- function(..., size = 64) {
  x <- c(...)
  x <- sort(unique(x), decreasing = TRUE)
  right <- (seq_along(x) - 1) * size
  
  res <- glue::glue(
    '![](hexes/<x>.png){.absolute top=-20 right=<right> height="<size * 1.16>"}',
    .open = "<", .close = ">"
  )
  
  paste0(res, collapse = " ")
}

# devtools::install_github("gadenbuie/countdown")
library(countdown)