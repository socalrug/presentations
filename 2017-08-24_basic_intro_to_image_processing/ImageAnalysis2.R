# Install EBImage
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("EBImage")

# Read Image
library(EBImage)
Img1 <- readImage("C:\\Users\\Oluyemi\\Desktop\\RDEMO\\island.jpg")

#### Exploratory Image Analysis
# Plot data
hist(Img1)

# Manipulating brightness
# Light (Increase brightness)
a <- Img1 + 0.1
print(a)
hist(a)
display(a)

# Dark (Decrease brightness)
dark <- Img1 - 0.4
print(dark)
hist(dark)
display(dark)

# Manipulating contrast
con.1<- Img1*0.6
display(con.1)
con.2 <- Img1*3
display(con.2)

# Gamma Correction
gam.1 <- Img1^0.5
display(gam.1)
gam.2 <- Img1^3
display(gam.2)

# Color
colorMode(Img1) <- Grayscale
print(Img1)
display(Img1)

colorMode(Img1) <- Color #to return to color


# New image file
writeImage(k, "NewImage.jpg")

# Flip, Flop, Rotate, resize
fli <- flip(Img1); flo<- flop(Img1)
display(fli);display(flo)
rot8 <- rotate(Img1, 90);display(rot8)
rsz <- resize(Img1, 400);display(rsz)

install.packages("imager")
library(imager)

plot(Img1)

class(Img1)

Img1

grayscale(Img1)

#To
mean(Img1);sd(Img1)


Img2<-boats
plot(Img2)
#controlling for the pixel value conversion
# The function rgb is a colour scale, i.e., 
#it takes pixel values and returns colours
rgb(1,0,1)

rgb(0,1,0)

rgb(0,0,1)

cscale <- function(v) rgb(0,0,v)
library(magrittr)
grayscale(Img2) %>% plot(colourscale=cscale,rescale=FALSE)

#install.packages("ggplot2")
library(ggplot2)

## data.frame
Imgdf <- as.data.frame(Img2)
head(Imgdf,5)

Imgdf <- plyr::mutate(Imgdf,channel=factor(cc,labels=c('R','G','B')))
ggplot(Imgdf,aes(value,col=channel))+geom_histogram(bins=30)+facet_wrap(~ channel)




# Special thanks to Simon Barthelmé

#for more go to 
#https://dahtah.github.io/imager/gettingstarted.html