library(mlr)
source("0_split_data.R")
#The entire structure of this package relies on this premise: 
# Create a Task. Make a Learner. Train Them.
# credit a task
trainTask <- makeClassifTask(data=credit_train, target="default")
testTask <- makeClassifTask(data=credit_test, target="default")

#cool discription of the training data. however Positive class is N
trainTask <- makeClassifTask(data = credit_train,target = "default", positive = "yes")
str(getTaskData(trainTask))
getParamSet("classif.rpart")
makeatree <- makeLearner("classif.rpart", predict.type = "response")
set_cv <- makeResampleDesc("CV",iters = 4L)
gs <- makeParamSet(
makeIntegerParam("minsplit",lower = 10, upper = 50),
makeIntegerParam("minbucket", lower = 5, upper = 50),
makeNumericParam("cp", lower = 0.001, upper = 0.2)
)
gscontrol <- makeTuneControlGrid()
stune <- tuneParams(learner = makeatree, resampling = set_cv, task = trainTask, par.set = gs, control = gscontrol, measures = acc)

#using hyperparameters for modeling
t.tree <- setHyperPars(makeatree, par.vals = stune$x)

#train the model
t.rpart <- train(t.tree, trainTask)
getLearnerModel(t.rpart)

#make predictions
tpmodel <- predict(t.rpart, testTask)

##########Tune result:
#Op. pars: minsplit=10; minbucket=15; cp=0.001
#acc.test.mean=0.7437500

getParamSet("classif.randomForest")

#create a learner
rf <- makeLearner("classif.randomForest", predict.type = "response", par.vals = list(ntree = 200, mtry = 3))
rf$par.vals <- list(
  importance = TRUE
)

#set tunable parameters
#grid search to find hyperparameters
rf_param <- makeParamSet(
  makeIntegerParam("ntree",lower = 50, upper = 500),
  makeIntegerParam("mtry", lower = 3, upper = 10),
  makeIntegerParam("nodesize", lower = 10, upper = 50)
)

#let's do random search for 50 iterations
rancontrol <- makeTuneControlRandom(maxit = 50L)

#set 3 fold cross validation
set_cv <- makeResampleDesc("CV",iters = 3L)

#hypertuning
rf_tune <- tuneParams(learner = rf, resampling = set_cv, task = trainTask, par.set = rf_param, control = rancontrol, measures = acc)


 