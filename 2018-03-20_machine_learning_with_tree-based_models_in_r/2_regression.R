library(rpart)
library(rpart.plot)
library(ModelMetrics)
source("1_split_data_grade.R")
# Train the model
grade_model <- rpart(formula = final_grade ~ ., 
                     data = grade_train, 
                     method = "anova")

# Look at the model output                      
print(grade_model)

# Plot the tree model
rpart.plot(x = grade_model, yesno = 2, type = 0, extra = 0)

# Generate predictions on a test set
pred <- predict(object = grade_model,   # model object 
                newdata = grade_test)  # test dataset

# Compute the RMSE
rmse(actual =grade_test$final_grade , 
     predicted = pred)

# Plot the "CP Table"
plotcp(grade_model)

# Print the "CP Table"
print(grade_model$cptable)

# Retreive optimal cp value based on cross-validated error
opt_index <- which.min(grade_model$cptable[, "xerror"])
print(opt_index)
cp_opt <- grade_model$cptable[opt_index, "CP"]
print(cp_opt)
# Prune the model (to optimized cp value)
grade_model_opt <- prune(tree = grade_model, 
                         cp = cp_opt)

# Plot the optimized model
rpart.plot(x = grade_model_opt, yesno = 2, type = 0, extra = 0)

# Establish a list of possible values for minsplit and maxdepth
minsplit <- seq(1, 4, 1)
maxdepth <- seq(1, 6, 1)

# Create a data frame containing all combinations 
hyper_grid <- expand.grid(minsplit = minsplit, maxdepth = maxdepth)

# Check out the grid
head(hyper_grid)

# Print the number of grid combinations
nrow(hyper_grid)

# Number of potential models in the grid
num_models <- nrow(hyper_grid)

# Create an empty list to store models
grade_models <- list()

# Write a loop over the rows of hyper_grid to train the grid of models
for (i in 1:num_models) {
  
  # Get minsplit, maxdepth values at row i
  minsplit <- hyper_grid$minsplit[i]
  maxdepth <- hyper_grid$maxdepth[i]
  
  # Train a model and store in the list
  grade_models[[i]] <- rpart(formula = final_grade ~ ., 
                             data = grade_train, 
                             method = "anova",
                             minsplit = minsplit,
                             maxdepth = maxdepth)
}
# Number of potential models in the grid
num_models <- length(grade_models)

# Create an empty vector to store RMSE values
rmse_values <- c()

# Write a loop over the models to compute validation RMSE
for (i in 1:num_models) {
  
  # Retreive the i^th model from the list
  model <- grade_models[[i]]
  
  # Generate predictions on grade_valid 
  pred <- predict(object = model,
                  newdata = grade_valid)
  
  # Compute validation RMSE and add to the 
  rmse_values[i] <- rmse(actual = grade_valid$final_grade, 
                         predicted = pred)
}

# Identify the model with smallest validation set RMSE
best_model <- grade_models[[which.min(rmse_values)]]

# Print the model paramters of the best model
best_model$control

# Compute test set RMSE on best_model
pred <- predict(object = best_model,
                newdata = grade_test)
rmse(actual = grade_test$final_grade, 
     predicted = pred)