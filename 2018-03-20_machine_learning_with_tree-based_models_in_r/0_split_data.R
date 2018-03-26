credit <- read.csv("https://assets.datacamp.com/production/course_3022/datasets/credit.csv")
# Total number of rows in the credit data frame
n <- nrow(credit)
# Number of rows for the training set (80% of the dataset)
n_train <- round(0.80 * n) 

# Create a vector of indices which is an 80% random sample
set.seed(123)
train_indices <- sample(1:n, n_train)

# Subset the credit data frame to training indices only
credit_train <- credit[train_indices, ]  

# Exclude the training indices to create the test set
credit_test <- credit[-train_indices, ]  