grade<-read.csv("https://assets.datacamp.com/production/course_3022/datasets/grade.csv")

# Look/explore the data
str(grade)

# Randomly assign rows to ids (1/2/3 represents train/valid/test)
# This will generate a vector of ids of length equal to the number of rows
# The train/valid/test split will be approximately 70% / 15% / 15% 
set.seed(1)
assignment <- sample(1:3, size = nrow(grade), prob = c(0.70, 0.15, 0.15) , replace = TRUE)

# Create a train, validation and tests from the original data frame 
grade_train <- grade[assignment == 1, ]    # subset the grade data frame to training indices only
grade_valid <- grade[assignment == 2, ]  # subset the grade data frame to validation indices only
grade_test <- grade[assignment == 3, ]   # subset the grade data frame to test indices only