############################################################
# Regression : 4 different strategies
# 1. Using R 'lm' function
# 2. Using TensorFlow directly
# 3. Using Keras with tensorFlow as background
# 4. Using tfestimator API
#
###########################################################
# Inout data
#
# Create 100 x, y data points, y = x * 0.1 + 0.3 + random error
#
set.seed(0)
x_data <- runif(100, min=0, max=1)
y_data <- x_data * 0.1 + 0.3 + runif(100, min=0.45, max=0.55)
plot(x_data, y_data)

###########################################################
# 1. Regression using R 'lm' function
#
model = lm(y_data~x_data)
summary(model)
abline(model,lwd=3,col="red")

#########################################################
# 2. Using TensorFlow directly
#
# Try to find values for W and b that compute 
# y_data = W * x_data + b + random error
#
library(tensorflow)

W <- tf$Variable(tf$random_uniform(shape(1L), -1.0, 1.0))
b <- tf$Variable(tf$zeros(shape(1L)))
y <- W * x_data + b

# Minimize the mean squared errors.
loss <- tf$reduce_mean((y - y_data) ^ 2)
optimizer <- tf$train$GradientDescentOptimizer(0.5)
train <- optimizer$minimize(loss)

# Launch the graph and initialize the variables.
sess = tf$Session()
sess$run(tf$global_variables_initializer())

# Fit the line (Learns best fit is W: 0.1, b: 0.3)
for (step in 1:201) {
  sess$run(train)
  if (step %% 20 == 0)
    cat(step, "-", sess$run(W), sess$run(b), "\n")
}

############################################################
# 3. Using Keras with TensorFlow as background
#
library(keras)

# Create Model
model <- keras_model_sequential()

model %>% 
  layer_dense(units = 5, activation = 'relu', input_shape = c(1)) %>%
  layer_dense(units = 1)

# Compile
model %>% compile(loss = 'mse',
                  optimizer = 'rmsprop',
                  metrics = 'mae')

# Fit Model
mymodel <- model %>%
  fit(x_data,
      y_data,
      epochs = 100,
      batch_size = 100)

#############################################################
