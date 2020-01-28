# The only package you'll need installed ahead of time is pacman.
# install.packages("pacman")

# With the p_load() function, all packages specified are installed and loaded or just loaded if already available.
pacman::p_load(reticulate, tidyverse, lubridate, ggthemes, janitor)

# Let's specify the path the version of python you'd like to use inside the R session.
use_python("/Users/michaelespero/opt/anaconda3/bin/python")

# Now that the path to the desired version of python is specified, let's check that python is available in RStudio.
# The initialize argument gets python started if it's not already.
py_available(initialize = T)

# With python available we can check to see if some of the python modules we want to use are ready.
py_module_available(module = "numpy")

py_module_available(module = "pandas")

py_module_available(module = "sklearn")

py_module_available(module = "nltk")

# Lastly, we can check out the python configuration in RStudio with the py_config() function.
py_config()

# At this point R and Python may be ready to work together. 
# We'll go over things like installing Python modules and statistics/data science workflows in R and Python.




