#################################################
# TensorFlow and R
#
################################################
library(tensorflow)

#####################################################
# Version number of TensorFlow
#
tensorflow::tf_config()

######################################################
# 1. Add operation
#
sess = tf$Session()

a <- tf$constant( c(5,3,8), shape = c(1L, 3L))
dim(a)
a
sess$run(a)
#####################
b <- tf$constant(c(3,-1,2), shape = c(1L, 3L))
dim(b)
b
sess$run(b)

#####################
c = tf$add(a,b)
dim(c)
c
sess$run(c)

#######################################################
# 2. Run the graph in a session

# Launch the default graph.
a <- tf$constant(3, dtype = tf$float32, name = "a")
b <- tf$constant(5, dtype = tf$float32, name = "b")
c <- list(a, b)
sess = tf$Session()
print(sess$run(c))
sess$close()

#######################################################
# 3. Session closes automatically when used inside a 'with'
#
a <- tf$constant(3, dtype = tf$float32, name = "a")
b <- tf$constant(5, dtype = tf$float32, name = "b")
c <- list(a, b)
with(tf$Session() %as% sess, {
  print(sess$run(c))
})

#######################################################
# Devices are specified within a string (Did not work)
#
#with(tf$Session() %as% sess, {
#  with(tf$device("/cpu:0"), {
#    c <- sess$run(c(a, b))
#    print(c)
#  })
#})

#######################################################
# 4. Element wise Mathematical Operation
# Add

a <- tf$constant(3, dtype = tf$float32, name = "a")
b <- tf$constant(5, dtype = tf$float32, name = "b")
add = tf$add(a, b, name = "add")
with (tf$Session() %as% sess,{
  print(sess$run(add))
})

######################################################
# 5. Multiply
#
a <- tf$constant(3, dtype = tf$float32, name = "a")
b <- tf$constant(5, dtype = tf$float32, name = "b")
mul = tf$multiply(a, b)
with (tf$Session() %as% sess,{
  print(sess$run(mul))
})

######################################################
# 6. Divide
#
a <- tf$constant(3, dtype = tf$float32, name = "a")
b <- tf$constant(5, dtype = tf$float32, name = "b")
div <- tf$div(a, b)
with (tf$Session() %as% sess,{
  results <- sess$run(div)
  print(results)
})

#####################################################
# 7. Matrix Multiplication
#
a <- tf$constant(c(1, 2), shape = c(1L, 2L), name = "a")
dim(a)
b <- tf$constant(c(3, 4), shape = c(2L, 1L), name = "b")
dim(b)
c <- tf$matmul(a, b, name = "mat_mul")
dim(c)
with (tf$Session() %as% sess,{
  sess$run(c)
})

#######################################################
# 8. Transpose
#
a <- tf$constant(c(1, 2, 3, 4), shape = c(2L, 2L), name = "a")
b <- tf$transpose(a, name = "transpose")
with (tf$Session() %as% sess,{
  print(sess$run(a))
  sess$run(b)
})

######################################################
# 9. Matrix Inverse
#
a <- tf$constant(c(1, 2, 3, 4), shape = c(2L, 2L))
b <- tf$matrix_inverse(a, name = "inverse")
c <- tf$matmul(a, b, name = "mat_mul")
with (tf$Session() %as% sess,{
  print(sess$run(a))
  print(sess$run(b))
  print(sess$run(c))
})

##################################################
# 10. Matrix Determinant
#
a <- tf$constant(c(1, 2, 3, 4), shape = c(2L, 2L))
b <- tf$matrix_determinant(a, name = "determinant")
with (tf$Session() %as% sess,{
  print(sess$run(a))
  print(sess$run(b))
})

###############################################
# 11. Array Operations - Concat
#
a <- tf$constant(c(1, 2), shape = c(1L, 2L), name = "a")
b <- tf$constant(c(3, 4), shape = c(1L, 2L), name = "b")
c <- tf$concat(list(a,b), axis = 0L,   name = "concat") # 
with (tf$Session() %as% sess,{
  print(sess$run(a))
  print(sess$run(b))
  print(sess$run(c))
})

################################################
# 12. Slice
#
a <- tf$constant(c(1, 2, 3, 4, 5, 6), shape = c(1L, 2L, 3L), name = "a")
c <- tf$slice(a, begin = c(0L,0L,0L), size = c(1L,1L,3L),  name = "slice") # 
with (tf$Session() %as% sess,{
  print(sess$run(a))
  print("Sliced")
  sess$run(c)
})

##################################################
# 13. Split
#
a <- tf$constant(1:20, shape = c(4L, 5L), name = "a")
l <- tf$split(a, c(1L, 2L, 2L), axis = 1L)
with (tf$Session() %as% sess,{
  print(sess$run(a))
  sess$run(l)
})

################################################
# 14. Shape
#
a <- tf$constant(1:20, shape = c(4L, 5L), name = "a")
with (tf$Session() %as% sess,{
  print(sess$run(a))
  sess$run(tf$shape(a))
})

################################################
# 15. Area of a triangle
#
sess = tf$Session()

a <- tf$constant(5.0, dtype = tf$float32, name = "a")
b <- tf$constant(3.0, dtype = tf$float32, name = "b")
c <- tf$constant(7.1, dtype = tf$float32, name = "b")
s = (a+b+c)/2
a = tf$sqrt(s*(s-a)*(s-b)*(s-c))

sess$run(a)

a <- tf$constant(2.3, dtype = tf$float32, name = "a")
b <- tf$constant(4.1, dtype = tf$float32, name = "b")
c <- tf$constant(4.8, dtype = tf$float32, name = "b")
s = (a+b+c)/2
a = tf$sqrt(s*(s-a)*(s-b)*(s-c))

sess$run(a)

###################################################



