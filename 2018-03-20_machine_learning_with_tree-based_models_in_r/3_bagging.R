
source("0_split_data.R")
library(ipred)

library(ModelMetrics)
library(caret)
# Bagging is a randomized model, so let's set a seed (123) for reproducibility
set.seed(123)

# Train a bagged model
credit_model <- bagging(formula = default ~ ., 
                        data = credit_train,
                        coob = TRUE)

# Print the model
print(credit_model)

# Generate predicted classes using the model object
class_prediction <- predict(object = credit_model ,    
                            newdata = credit_test,  
                            type = "class")  # return classification labels

# Print the predicted classes
print(class_prediction)

# Calculate the confusion matrix for the test set
confusionMatrix(data = class_prediction,       
                reference = credit_test$default)  

# Generate predictions on the test set
pred <- predict(object = credit_model,
                newdata = credit_test,
                type = "prob")

# `pred` is a matrix
class(pred)

# Look at the pred format
head(pred)

# Compute the AUC (`actual` must be a binary (or 1/0 numeric) vector)
credit_ipred_model_test_auc <- auc(actual = ifelse(credit_test$default == "yes", 1, 0), 
    predicted = pred[,"yes"]) 

# Specify the training configuration
ctrl <- trainControl(method = "cv",     # Cross-validation
                     number = 5,      # 5 folds
                     classProbs = TRUE,                  # For AUC
                     summaryFunction = twoClassSummary)  # For AUC

# Cross validate the credit model using "treebag" method; 
# Track AUC (Area under the ROC curve)
set.seed(1)  # for reproducibility
credit_caret_model <- train(default ~ .,
                            data = credit_train, 
                            method = "treebag",
                            metric = "ROC",
                            trControl = ctrl)

# Look at the model object
print(credit_caret_model)

# Inspect the contents of the model list 
names(credit_caret_model)

# Print the CV AUC
credit_caret_model$results[,"ROC"]

# Generate predictions on the test set
pred <- predict(object = credit_caret_model , 
                newdata = credit_test,
                type = "prob")

# Compute the AUC (`actual` must be a binary (or 1/0 numeric) vector)
credit_caret_model_test_auc <- auc(actual = ifelse(credit_test$default == "yes", 1, 0), 
    predicted = pred[,"yes"])

# Print ipred::bagging test set AUC estimate
print(credit_ipred_model_test_auc)

# Print caret "treebag" test set AUC estimate
print(credit_caret_model_test_auc)

# Compare to caret 5-fold cross-validated AUC
credit_caret_model$results[,2 ]