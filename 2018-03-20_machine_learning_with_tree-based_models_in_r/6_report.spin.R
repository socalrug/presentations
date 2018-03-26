library(rpart)
library(rpart.plot)
library(ModelMetrics)
library(caret)
library(ipred)
library(randomForest)
source("0_split_data.R")
credit_model1 <- rpart(formula = default ~ ., 
                       data = credit_train, 
                       method = "class",
                       parms = list(split = "gini"))

# Train an information-based model
credit_model2<- rpart(formula = default ~ ., 
                       data = credit_train, 
                       method = "class",
                       parms = list(split = "information"))
credit_model3 <- bagging(formula = default ~ .,  data = credit_train,    coob = TRUE)
credit_model4 <- randomForest(formula = default ~ .,    data = credit_train)

pred1 <- predict(object = credit_model1, 
                 newdata = credit_test,
                 type = "class")    

# Generate predictions on the validation set using the information model
pred2 <- predict(object = credit_model2, 
                 newdata = credit_test,
                 type = "class")

# Generate predictions on the test set
pred3 <- predict(object = credit_model3, 
                newdata = credit_test,
                type = "class")
pred4 <- predict(object =credit_model4 ,   # model object 
                            newdata = credit_test,  # test dataset
                            type = "class")

cm1 <- confusionMatrix(data = pred1,       
                reference = credit_test$default)  
cm2 <- confusionMatrix(data = pred2,       
                       reference = credit_test$default)  
cm3 <- confusionMatrix(data = pred3,       reference = credit_test$default)  
cm4 <- confusionMatrix(data = pred4,       
                       reference = credit_test$default)  

re <- data.frame(gini=cm1$overall[1], 
                 info=cm2$overall[1], 
                 bagging=cm3$overall[1],
                 rf=cm4$overall[1])
re
