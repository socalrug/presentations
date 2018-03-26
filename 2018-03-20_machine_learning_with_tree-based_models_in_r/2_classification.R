library(rpart)
library(rpart.plot)
library(ModelMetrics)
library(caret)
source("0_split_data.R")
# Train the model (to predict 'default')
credit_model <- rpart(formula = default~., 
                      data = credit_train, 
                      method = "class")

# Look at the model output                      
print(credit_model)
rpart.plot(x = credit_model, yesno = 2, type = 0, extra = 0)
plotcp(credit_model)
# Generate predicted classes using the model object
class_prediction <- predict(object = credit_model,  
                            newdata = credit_test,   
                            type = "class")  


pred <- predict(object = credit_model, 
                 newdata = credit_test,
                 type = "class") 
ce(actual = credit_test$default, 
   predicted = pred)

rpart.plot(x = credit_model, yesno = 2, type = 0, extra = 0)
plotcp(credit_model)
# Calculate the confusion matrix for the test set
confusionMatrix(data = class_prediction,       
                reference = credit_test$default)  

# Train a gini-based model
credit_model1 <- rpart(formula = default ~ ., 
                       data = credit_train, 
                       method = "class",
                       parms = list(split = "gini"))

# Train an information-based model
credit_model2 <- rpart(formula = default ~ ., 
                       data = credit_train, 
                       method = "class",
                       parms = list(split = "information"))

# Generate predictions on the validation set using the gini model
pred1 <- predict(object = credit_model1, 
                 newdata = credit_test,
                 type = "class")    

# Generate predictions on the validation set using the information model
pred2 <- predict(object = credit_model2, 
                 newdata = credit_test,
                 type = "class")

# Compare classification error
ce(actual = credit_test$default, 
   predicted = pred1)
ce(actual = credit_test$default, 
   predicted = pred2)

rpart.plot(x = credit_model1, yesno = 2, type = 0, extra = 0)
plotcp(credit_model1)

rpart.plot(x = credit_model2, yesno = 2, type = 0, extra = 0)
plotcp(credit_model2)