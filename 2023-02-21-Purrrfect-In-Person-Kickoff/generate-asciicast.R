library(asciicast)

cast <- record("map-asciicast.R")

my_theme <- mytheme <- modifyList(
  default_theme(),
  list(background = c(240, 242, 241),
       text = c(95, 73, 56))
)

write_svg(cast, "map-asciicast.svg", window = FALSE, theme = my_theme)
