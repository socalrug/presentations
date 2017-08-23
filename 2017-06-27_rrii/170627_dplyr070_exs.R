#====
# dplyr 0.7.0 Examples
# Author: R.Benz
# Date:  06/26/2017
#
# Miscellaneous examples of new features
# in dplyr 0.7.0
# See: https://blog.rstudio.org/2017/06/13/dplyr-0-7-0/
#

library(tidyverse)


#=== new 'pull' verb ===

# Output from data.frame column subsetting depends
# on how many columns you request
# If you select 1 column, you'll get a vector
iris[, "Species"]
# If you select >1 column, you'll get a data frame
head(iris[, c("Sepal.Length", "Species")])

# 'select' verb always returns a tibble or data.frame
# even if the result is just 1 column
iris %>% as_tibble %>% select(Species)

# To allow for standard single column behavior
# in dplyr pipelines, use 'pull'
iris %>% pull(Species)




#=== 'case_when' can be used in mutate

# In dplyr pipelines, if you wanted to add
# new columns based upon the conditions of
# other columns, you probably needed to use
# if_else statements, possible nested ones.
# That's a pain, and 'case_when' can help.
mtcars %>%
  as_tibble %>%
  select(mpg, am) %>%
  mutate(
    car_type = case_when(
      mpg > 20 & am == 0 ~ 'type 1',
      mpg > 20 & am == 1 ~ 'type 2',
      TRUE ~ 'type 3'
    ))



#=== tidy evaluation in dplyr pipelines

# tidy evalution allow you to reference
# input data frame columns through variables
# in a consistent and correct way.

# First, let's start with a basic dplyr pipeline
iris %>% 
  group_by(Species) %>%
  summarize(mean_len = mean(Sepal.Length))

# Now let's try to encode the group_by column
# as a variable
# This DOESN'T work
my_col <- Species
iris %>% 
  group_by(my_col) %>%
  summarize(mean_len = mean(Sepal.Length))

# Nor does this
my_col <- "Species"
iris %>% 
  group_by(my_col) %>%
  summarize(mean_len = mean(Sepal.Length))

# Prior to v0.7.0, you could use '_' function twins
# to accomplish the task, but this is now deprecated
# with the new tidy eval system
my_col <- "Species"
iris %>% 
  group_by_(my_col) %>%
  summarize(mean_len = mean(Sepal.Length))


# tidy evaulation allows you to use variables for
# column names in dplyr pipelines using a data
# structure called a quosure.
my_col <- quo(Species)

iris %>% 
  group_by(!!my_col) %>%
  summarize(mean_len = mean(Sepal.Length))
  

# Or we could write a function
my_summary <- function(grp_colname) {
  grp_col <- enquo(grp_colname)
  
  iris %>%
    group_by(!!grp_col) %>%
    summarize(mean_len = mean(Sepal.Length))
}

my_summary(Species)


