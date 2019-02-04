
# For the gapminder dataset
library(gapminder)
# For all the tidyverse core packages
library(tidyverse)


#=== Examples of data.frames vs. tibbles

# iris is a data.frame
iris

# starwars (from the dplyr package) is a tibble
starwars


#=== Examples using list columns with complex objects

# We can add data frames as a list into the main data frame
#  because we are using a tibble
my_favorites <- tibble(dataset_name = c("iris", "mtcars", "starwars"),
                       data = list(iris, mtcars, starwars))
my_favorites

# This doesn't work (as written...) because we are using data.frame 
#  uncomment to test it out
# my_favorites_bad <- data.frame(dataset_name = c("iris", "mtcars", "starwars"),
#                                data = list(iris, mtcars, starwars))

# You can even have different types inside of list column elements
crazy_tbl <- tibble(data_type = c("a number", 
                                  "a char", 
                                  "a plot"), 
                    list_item = list(1, 
                                     "this is a string", 
                                     ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()))
crazy_tbl


#=== Examples using nested data frames, data pipelines and purrr
gapminder


# Nest the data by country, continent
gapm_nested <- gapminder %>%
  group_by(country, continent) %>%
  nest()

gapm_nested


# Add a linear model
gapm_model <- gapminder %>%
  group_by(country, continent) %>%
  nest() %>%
  mutate(model = map(data, function(d) {
    lm(lifeExp ~ year, data = d)
  }))

gapm_model


# Add plots, models and summaries
cntry_grps <- gapminder %>% 
  group_by(country, continent) %>% 
  nest() %>%
  mutate(plot = map2(country, data, function(cntry, d) {
    ggplot(d, aes(year, lifeExp)) + 
      geom_point() +
      geom_line() +
      ggtitle(cntry)
  })) %>%
  mutate(plot2 = map(plot, function(plt) {
    plt + geom_smooth(method = "lm")
  })) %>%
  mutate(model = map(data, function(d) {
    lm(lifeExp ~ year, data = d)
  })) %>%
  mutate(model_summary = map(model, broom::glance),
         rsq = map_dbl(model_summary, "r.squared")) %>%
  arrange(desc(rsq))

cntry_grps

