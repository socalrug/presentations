####################################################
# Implementation of Adam in R: Self Equation
#
# 4-22-19: After Caltech DL-TF class ended on 4-20-19
#
####################################################
rm (list=ls(all=TRUE))

###################################################
# Data set
# Read data
#
concrete <- read.csv("concrete.csv")
head(concrete)
class(concrete)

#####################################################
# custom normalization function
#
normalize <- function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}
# apply normalization to entire data frame
concrete_norm <- as.data.frame(lapply(concrete, normalize))

head(concrete_norm)
class(concrete_norm)
dim(concrete_norm)

#######################################################
# Split data into Train + Test
#
concrete_train <- concrete_norm[1:773, ]
concrete_test <- concrete_norm[774:1030, ]

concrete_train_x <- concrete_train[,1:3]
concrete_train_y <- concrete_train[9]

head(concrete_train_x)
class(concrete_train_x)

head(concrete_train_y)
class(concrete_train_y)
########################################################
# 1. Linear Regression using the 'lm' function
#
d = cbind(concrete_train_x,concrete_train_y)
class(d)
#head(d)
linearModel = lm (strength ~ cement + slag + ash, data = d)
summary(linearModel)

#######################################################
# Extra Data Manipulation in Self Equation
# Add 1 in the first column of 'concrete_train_x' data
# Convert both 'concrete_train_x' and 'concrete_train_y' into matrix
#
concrete_train_x_m <- matrix(as.numeric(unlist(concrete_train_x)),ncol=3)
concrete_train_x_m <- cbind(rep(1,nrow(concrete_train_x)),concrete_train_x_m)

concrete_train_y_m <- matrix(as.numeric(unlist(concrete_train_y)),ncol=1)

head(concrete_train_x_m)
dim(concrete_train_x_m)
class(concrete_train_x_m)

head(concrete_train_y_m)
dim(concrete_train_y_m)
class(concrete_train_y_m)

#########################################################
# 2. Linear Regression using Matrix approach
#
# z1 = Inverse of (t(x) * x)
# z2 = t(x) * y
# Answer = z1 * z2
#
z1 = t(concrete_train_x_m) %*% concrete_train_x_m
z1
# comput the inverse of z
det(z1)
(invz1 = solve(z1))

################
z2 = t(concrete_train_x_m) %*% concrete_train_y_m
z2
##########################################
answer = invz1 %*% z2
answer

####################################################
# 3. Regression Using Adam Algorithm
#
# W is the weight vector 
# Initialize the weight vector
#
W <- array(c(0.,0.,0.,0.),dim=c(1,4))
X = concrete_train_x_m
Y = concrete_train_y_m

#####################################################
# ADAM Hyper Parameters
# learning Rate + epochs + epsilon
#
learningRate <- 0.01
epsilon <- 1e-8
  
#####################################################
# EWMA: Exponentially Weighted Moving Average
# Hyper parameters
#
beta1 <- 0.9
beta2 <- 0.999
  
###################################################
# Initial value of 'm' and 'v' is zero
m <- 0
v <- 0
  
epochs <- 1000
l <- nrow(Y)
costHistory <- array(dim=c(epochs,1))

for(i in 1:epochs) {
    # 1. Computed output: h = x values * weight Matrix
    h = X %*% t(W)
    
    # 2. Loss = Computed output - observed output
    loss = h - Y
 
    error = (h - Y)^2
    costHistory[i] = sum(error)/(2*nrow(Y))
    
    # 3. gradient = loss * X
    gradient = (t(loss) %*% X)/l
    
    # 4. calculate new W weight values
    m = beta1*m + (1 - beta1)*gradient
    v = beta2*v + (1 - beta2)*(gradient^2) 
    
    # 5. corrected values Bias Correcttion
    m_hat = m/(1 - beta1^i)
    v_hat = v/(1 - beta2^i)
    
    # 6. Update the weights
    W = W - learningRate*(m_hat/(sqrt(v_hat) + epsilon))
}


############################################
print(W)

plot(costHistory,type='l')
