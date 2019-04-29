#########################################################
#
# Gradient Decent
#
rm(list=ls(all=TRUE))

#########################################################
x = c(0,1,2,3,4)
y = c(1,3,7,13,21)

plot(x,y)

model = lm(y~x)
summary(model)
abline(model)

#####################################################
# Plot the RSS Function
#
b = -1
m = seq(-25,25,0.1)

RSSHistory = rep(0,length(m))
index = 0

for ( i in m ) { 
  index = index + 1
  computed.Value = i*x + b
  error = y - computed.Value
  RSSHistory[index] = sum(error^2)
}


plot(m,RSSHistory,type="l")

min(RSSHistory)
slopeMin = m[which(RSSHistory == min(RSSHistory))]
abline(v=slopeMin, col='red')


######################################################

dRSS_dm = function (m,b) {-2*sum((y-m*x-b)*x)  }
dRSS_db = function (m,b) { -2*sum(y-m*x-b) }

mStart = bStart = 0
learningRate = 0.01;  maxLimit = 500

mHistory = bHistory = rep(0,maxLimit)

for ( i in 1:maxLimit )
{
  mHistory[i] = mStart
  bHistory[i] = bStart
  
  dW = dRSS_dm(mStart,bStart)
  db = dRSS_db(mStart,bStart)
  
  mStart = mStart - learningRate * dW
  bStart = bStart - learningRate * db
}

plot(mHistory,type='l')
plot(bHistory,type='l')

