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
xStart = -4.0
learningRate = 0.1
maxLimit = 1000
xStartHistory = rep(0,maxLimit)

for ( i in 1:maxLimit )
{
  xStartHistory[i] = xStart
  xStart = xStart - learningRate * dy_dx(xStart)
}

plot(xStartHistory,type='l',ylim=c(-5,3), main="After 1,000 Iterations")
text(500,-2.5,"X Value")

abline(h=2, col='dark red', lwd=3)
text(500,2.5,"Minimum Point")

################################################
