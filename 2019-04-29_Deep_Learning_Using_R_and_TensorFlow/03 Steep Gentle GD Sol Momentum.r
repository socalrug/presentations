#########################################################
#
# Gradient Decent
# Steep versus gentle slope
#
#
rm(list=ls(all=TRUE))

#################################################
# Example#1
#
x = seq(-5,5,0.1)
y1 = 1 - exp(-(x-2)^2)

plot(x,y1,type='l',ylim=c(-2,2),lwd=3)
text(-2,1.2,"Error Function")
text(2,1.4,"Minimum Point")
abline(v=2)

dy_dx = function (w1) { 2*(w1-2)*exp(-(w1-2)^2) }

slope = dy_dx(x)
points(x,slope,type='l',col='red')
text(-2,0.2,"Derivative of Error Function")

############################################
xStart = -2.0
learningRate = 0.1

#########################################
# Momentum
#
maxLimit = 160000
xStartHistory = rep(0,maxLimit)
gamma = 0.9
update = 0

for ( i in 1:maxLimit )
{
  xStartHistory[i] = xStart 
  gradient = dy_dx(xStart)
  
  update = (gamma * update) + (learningRate * gradient)
  xStart = xStart - update
  
  if ( i %% 1000 == 0 ) { cat ("i = ",i, "xstart = ", xStart, "\n")}
}

plot(xStartHistory,type='l')
abline(h=2,col='red')

######################################################
# Expand when the values are converging
#
xStartHistorySmall = xStartHistory[148500:149500]
plot(xStartHistorySmall,type='l')
abline(h=2,col='red')

#################################################



