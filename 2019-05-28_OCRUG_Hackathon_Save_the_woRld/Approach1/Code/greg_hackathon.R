# Data competition

# setwd("/Users/gregfaletto/Google Drive/Data Science/R/OCRUG Hackathon/Data")

# setwd("/Users/gregfaletto/Google Drive/Data Science/R/OCRUG Hackathon")

# setwd("/Users/gregfaletto/Documents/GitHub/OC-Data-Science-Hackathon-19")



rm(list=ls())   


# rm(list=ls()[!ls() %in% c("raw.covariate.dat", "raw.usage.dat", "citycounty",
	# "n.covariate", "n.usage", "region")])
# rm(list=ls()[!ls() %in% c("raw.dat", "data", "ruralurban",
	# "citycounty", "employer.names", "fortune500", desc.files)])

# Whether to re-load data
load.dat <- TRUE

############# Load Libraries #################

print("Loading libraries...")


# library(leaps)
# library(RANN)
# library(gpls)
# library(vcd) # used for assocstats (calculating cramer's v)

library(lattice)
library(grid)
# library(Amelia)
# library(ggplot2)
# library(caret)
# library(pls)
library(plyr)
# library(forecast)
# library(DMwR)
# library(penalized)
# library(elasticnet)
# library(gdata)
# library(MatchIt)
library(dplyr)
library(ggplot2)
library(glmnet)
library(gglasso)
library(stabs)
library(energy)
library(gam)
library(randomForest)
library(Metrics)
library(stargazer)
library(boot)
# library(googleway)
# library(lsr)


###### Set seed for reproducibility ######

set.seed(20197)

################ Parameters ################

print("Storing parameters...")

# # directory where output should be stored
# dir.out <- "/Users/gregoryfaletto/Documents/R/Citadel/Models"

# # directory where this R file lives
# dir.main <- "/Users/gregfaletto/Google Drive/Data Science/R/OCRUG Hackathon"

# # directory where R raw, processed data files live
# dir.dat <- "/Users/gregfaletto/Google Drive/Data Science/R/OCRUG Hackathon/Data"

# # directory where geographic data files live
# dir.geo <- "/Users/gregfaletto/Documents/R/ZipRecruiter/Geographic data"

# # directory for models
# dir.mod <- "/Users/gregoryfaletto/Documents/R/Citadel/Models"
# dir.mod <- "/Users/gregfaletto/Dropbox"

# # name of current unprocessed data file with covariates (for propensity score
# # prediction)
# dat.prop <- "msa_data.csv"

# name of current unprocessed data file with water usage (responses)
dat.chems <- "cal_chemicals.csv"

# # name of processed data file
# dat.proc <- paste("processed_", substr(dat.resp, 1, nchar(dat.resp)-3), "R",
# 	sep="")


# # ############# Load Data ####################

if(load.dat){
	print("Loading data...")

	t0 <- Sys.time()

	## Read in training and data data, the latter may take a few minutes to run
	# setwd(dir.dat)
	dir.main <- getwd()

	# Chemicals data
	setwd("External Data/Chemicals/")
	raw.cal.chemicals.dat <- read.csv(file=dat.chems)
	# 2010 health outcomes
	setwd(dir.main)
	setwd("External Data/Health Outcomes/")
	health.2010 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2011 health outcomes
	health.2011 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2012 health outcomes
	health.2012 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2013 health outcomes
	health.2013 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2014 health outcomes
	health.2014 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2015 health outcomes
	health.2015 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2016 health outcomes
	health.2016 <- read.csv(file="2016_health_outcomes_clean.csv", header=TRUE)
	# 2017 health outcomes
	health.2017 <- read.csv(file="2017_health_outcomes_clean.csv", header=TRUE)
	# 2018 health outcomes
	health.2018 <- read.csv(file="2018_health_outcomes_clean.csv", header=TRUE)

	# rurality data
	setwd(dir.main)
	setwd("External Data/Rurality/")
	rurality <- read.csv(file="ruralurbancodes2013.csv", header=TRUE)

	# agricultural use data
	setwd(dir.main)
	setwd("External Data/agricultural_use/")
	agricultural <- read.csv(file="data_213608.csv", header=TRUE)

	# earnings data
	setwd(dir.main)
	setwd("External Data/Earnings/")
	earnings <- read.csv(file="earnings.csv", header=TRUE)

	# Demographics data
	setwd(dir.main)
	setwd("External Data/Demographics/")
	demographics <- read.csv(file="cc-est2017-alldata-06.csv", header=TRUE)

	# # Propensity score matching data
	# raw.covariate.dat <- read.csv(file=dat.prop, head=TRUE, sep=",")
	# # Water usage (desired response)
	# raw.usage.dat <- read.csv(file=dat.resp, head=TRUE, sep=",")
	# # Earnings data
	# raw.earnings.dat <- read.csv(file="earnings.csv", head=TRUE, sep=",")
	# # City/county data
	# citycounty <- read.csv("us_cities_states_counties.csv", sep="|")
	# # make all county name lowercase
	# citycounty$County <- tolower(citycounty$County)
	# citycounty$City <- tolower(citycounty$City)
	# raw.usage.dat$COUNTY <- tolower(gsub(" County", "", raw.usage.dat$COUNTY))
	print("Data loaded!")
	setwd(dir.main)

	print("Time to load data:")
	print(Sys.time() - t0)
	
}

############ Duplicating data (so I keep a copy of raw unprocessed data file)

chemical_names <- levels(raw.cal.chemicals.dat$chemical_species)

years <- sort(unique(raw.cal.chemicals.dat$year))

fips <- sort(unique(raw.cal.chemicals.dat$fips))

# Construct data.frame for average chemical levels over 2000 - 2016
X.dat <- data.frame(fips)


# Average chemical levels over all years
for(i in 1:length(chemical_names)){
	# create a data.frame to temporarily hold averages for each county
	averages <- numeric(length(fips))
	for(j in 1:length(fips)){
		# For each fips, take the average level of this chemical over all years
		averages[j] <- mean(raw.cal.chemicals.dat[raw.cal.chemicals.dat$chemical_species==chemical_names[i] &
			raw.cal.chemicals.dat$fips==fips[j], "value"])
		# averages[j] <- median(raw.cal.chemicals.dat[raw.cal.chemicals.dat$chemical_species==chemical_names[i] &
		# 	raw.cal.chemicals.dat$fips==fips[j], "value"])
	}

	X.dat[, chemical_names[i]] <- averages
}

colnames(X.dat) <- c("FIPS", chemical_names)

# Remove NaN rows
for(i in 1:nrow(X.dat)){
	if(any(is.nan(as.matrix(X.dat[i,])))){
		X.dat <- X.dat[-i, ]
	}
}

# # Show example histogram
# pollutants.over.time <- raw.cal.chemicals.dat[raw.cal.chemicals.dat$chemical_species=="Nitrates" &
# 			raw.cal.chemicals.dat$fips==fips[4], "value"]

# df.pollutants.over.time <- data.frame(pollutants.over.time)
# colnames(df.pollutants.over.time) <- "Nitrates"

# plot.pollutant.over.time <- ggplot(df.pollutants.over.time, aes(x=Nitrates)) +
# 	geom_histogram()

# print(plot.pollutant.over.time)

# Re-name fips vector to only include remaining fips
fips <- X.dat$FIPS

# Add rurality levels to X
rurality.fips <- integer(length(fips))
for(j in 1:length(fips)){
	# For each fips, take the average level of this chemical over all years
	rurality.fips[j] <- rurality[rurality$FIPS==fips[j], "RUCC_2013"]
}

# Plot histogram of rurality levels
df.rurality <- data.frame(rurality.fips)

rurality.plot <- ggplot(df.rurality, aes(x=rurality.fips)) +
	geom_histogram(binwidth=1)
print(rurality.plot)

# Use coarser classification for rurality
rurality.fips[rurality.fips %in% c(3, 4, 5)] <- 3
rurality.fips[rurality.fips %in% c(6, 7, 8, 9)] <- 4

rurality.fips <- factor(rurality.fips, ordered=TRUE)

X.dat <- data.frame(X.dat, rurality.fips)
colnames(X.dat)[ncol(X.dat)] <- "rurality"

# X.dat$rurality <- as.factor(X.dat$rurality)

# Add percentage of land use for agriculture to X
percent.agricultural.fips <- integer(length(fips))
for(j in 1:length(fips)){
	# For each fips, take the average level of this chemical over all years
	percent.agricultural.fips[j] <- agricultural[agricultural$countyFIPS==fips[j],
	"Value"]
}

X.dat <- data.frame(X.dat, percent.agricultural.fips)
colnames(X.dat)[ncol(X.dat)] <- "pct.agricultural"

# Add earnings data to X
earnings.fips <- integer(length(fips))
for(j in 1:length(fips)){
	# For each fips, take the average level of this chemical over all years
	earnings.fips[j] <- earnings[earnings$fips==fips[j] & earnings$year==2016,
		"total_med"]
}

X.dat <- data.frame(X.dat, earnings.fips)
colnames(X.dat)[ncol(X.dat)] <- "earnings"

# Demographic data: remove all but last year, California data
demographics <- demographics[demographics$STNAME=="California" &
	demographics$YEAR==10, ]
# Add FIPS numbers to demographic data
raw.cal.chemicals.dat$county  <- tolower(gsub(" County", "",
	raw.cal.chemicals.dat$county))
demographics$CTYNAME <- tolower(gsub(" County", "", demographics$CTYNAME))

counties <- unique(demographics$CTYNAME)

fips <- numeric(nrow(demographics))
demographics <- data.frame(demographics, fips)
for(i in 1:length(counties)){
	if(any(raw.cal.chemicals.dat$county==counties[i])){
		demographics[demographics$CTYNAME==counties[i], "fips"] <-
			raw.cal.chemicals.dat[raw.cal.chemicals.dat$county==counties[i],
			"fips"][1]
	} else{
		print(paste("ERROR: no match for county", counties[i]))
	}
	
}

fips <- X.dat$FIPS

# Add over.65 (percentage of population over 65) data to X
over.65.fips <- integer(length(fips))
for(j in 1:length(fips)){
	# Find proportion of population over 65
	tot.over.65 <- sum(demographics[demographics$fips==fips[j] &
		demographics$AGEGRP>13, "TOT_POP"])
	tot.pop <- sum(demographics[demographics$fips==fips[j], "TOT_POP"])
	over.65.fips[j] <- tot.over.65/tot.pop
}

X.dat <- data.frame(X.dat, over.65.fips)
colnames(X.dat)[ncol(X.dat)] <- "pct.over.65"


# Add race data to X
white.fips <- integer(length(fips))
for(j in 1:length(fips)){
	# Find proportion of population over 65
	tot.white <- sum(demographics[demographics$fips==fips[j], c("WA_MALE",
		"WA_FEMALE")])
	tot.pop <- sum(demographics[demographics$fips==fips[j], "TOT_POP"])
	white.fips[j] <- tot.white/tot.pop
}

X.dat <- data.frame(X.dat, white.fips)
colnames(X.dat)[ncol(X.dat)] <- "pct.white"



# Response vector

Y <- numeric(length(fips))

for(j in 1:length(fips)){
	Y[j] <- health.2018[health.2018$FIPS==fips[j], "X..Fair.Poor"]
}

# Histogram of outcomes

dat.health <- data.frame(Y)

health.plot <- ggplot(dat.health, aes(x=Y)) + geom_histogram()
print(health.plot)

# # Save data
# write.csv(X.dat, file="X.csv")
# write.csv(Y, file="Y.csv")

# plot data
data.ggplot <- data.frame(X.dat[, -1], Y)

# histograms of variables--reasonable distributions?
arsenic.plot <- ggplot(data.ggplot, aes(x=Arsenic)) +geom_histogram()
print(arsenic.plot)

nitrates.plot <- ggplot(data.ggplot, aes(x=Nitrates)) +geom_histogram()
print(nitrates.plot)

uranium.plot <- ggplot(data.ggplot, aes(x=Uranium)) +geom_histogram()
print(uranium.plot)

# Try taking logarithms of pollutant levels
data.ggplot$Arsenic <- log(data.ggplot$Arsenic)
# colnames(data.ggplot)[colnames(data.ggplot)= "Arsenic"] <- "log(Arsenic)"
data.ggplot$Nitrates <- log(data.ggplot$Nitrates)
# colnames(data.ggplot)[colnames(data.ggplot)= "Nitrates"] <- "log(Nitrates)"
data.ggplot$Uranium <- log(data.ggplot$Uranium)
# colnames(data.ggplot)[colnames(data.ggplot)= "Uranium"] <- "log(Uranium)"

arsenic.plot <- ggplot(data.ggplot, aes(x=Arsenic)) +geom_histogram() +
	labs(x = "log(Arsenic)")
print(arsenic.plot)

nitrates.plot <- ggplot(data.ggplot, aes(x=Nitrates)) +geom_histogram() +
	labs(x="log(Nitrates)")
print(nitrates.plot)

uranium.plot <- ggplot(data.ggplot, aes(x=Uranium)) +geom_histogram() + 
	labs(x="log(Uranium)")
print(uranium.plot)

# ggplot(data=data.ggplot, aes(x=Arsenic, y=Y)) + geom_point()
# ggplot(data=data.ggplot, aes(x=DEHP, y=Y)) + geom_point()
# ggplot(data=data.ggplot, aes(x=Nitrates, y=Y)) + geom_point()
# ggplot(data=data.ggplot, aes(x=Uranium, y=Y)) + geom_point()

# # Fit lasso model
# model <- cv.glmnet(x=as.matrix(X.dat[, 2:ncol(X.dat)]), y=Y)

# linear.model <- lm(Y~Arsenic+Nitrates+Uranium+pct.agricultural+
# 	earnings+pct.over.65 + pct.white, data.ggplot)
linear.model.ints <- lm(Y~Arsenic+Nitrates+Uranium  + pct.agricultural
	+ earnings + pct.white +pct.over.65 + rurality + Arsenic:Nitrates + Arsenic:Uranium 
	+ Nitrates:Uranium , data.ggplot)

linear.model.ints.2 <- lm(Y~Nitrates + Arsenic + Uranium+ earnings + pct.over.65
	+ Arsenic:Uranium + Nitrates:Uranium + Arsenic:Nitrates, data.ggplot)


# Residual
data.resids <- data.frame(data.ggplot$Uranium, linear.model.ints.2$residuals)
colnames(data.resids) <- c("Nitrates", "Residuals")

residual.plot <- ggplot(data.resids, aes(x=Nitrates, y=Residuals)) +
	geom_point()
print(residual.plot)

# linear.model.ints.3 <- lm(Y~Nitrates + earnings + pct.over.65, data.ggplot)

# Linear model MSEs

mses <-c(
	# mse(Y, predict(linear.model)),
	mse(Y, predict(linear.model.ints)), 
	mse(Y, predict(linear.model.ints.2))
	# mse(Y, predict(linear.model.ints.3))
	)
mse.labels <- c(
	# "linear.model", 
	"linear.model.ints",
	"linear.model.ints.2"
	# "linear.model.ints.3"
	)



# X.pred <- model.matrix(X.dat[, -1])[, -1]

# Lasso model
formula <- as.formula(Y ~ .)
# Second step: using model.matrix to take advantage of f
X.pred <- model.matrix(formula, data.ggplot)[, -1]
lasso.fit <- cv.glmnet(x=X.pred, y=Y)

# Lasso model with interactions
formula.int <- as.formula(Y ~ .*.)
# Second step: using model.matrix to take advantage of f
X.pred.int <- model.matrix(formula.int, data.ggplot)[, -1]
lasso.fit.ints <- cv.glmnet(X.pred.int, Y)


# Lasso model only with interactions for chemicals
formula.chem.int <- as.formula(Y ~. + Arsenic:Nitrates + Nitrates:Uranium
	+ Arsenic:Uranium)
# Second step: using model.matrix to take advantage of f
X.pred.chem.int <- model.matrix(formula.chem.int, data.ggplot)[, -1]
lasso.fit.chem.ints <- cv.glmnet(X.pred.chem.int, Y)

mses <- c(mses, 
	mse(Y, predict(lasso.fit, newx=X.pred)),
	mse(Y, predict(lasso.fit.ints, newx=X.pred.int)),
	mse(Y, predict(lasso.fit.chem.ints, newx=X.pred.chem.int))
	)
mse.labels <- c(mse.labels, "lasso.fit", "lasso.fit.ints",
	"lasso.fit.chem.ints")

# # Stability selection
# stabs.selec <- stabsel(X.pred, Y, cutoff=0.55, q=5)

# Group lasso
groups <- c(1, 2, 3, 4, 5, 5, 5, 6, 7, 8, 9)
g.lasso.fit <- cv.gglasso(x=X.pred, y=Y, group=groups, nfolds=10)

# Group lasso with interactions
groups.ints <- c(1, 2, 3, 4, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13, 13, 14,
	15, 16, 17, 18, 19, 20, 20, 20, 21, 22, 23, 24, 25, 26, 26, 26, 27, 28, 29,
	30, 31, 31, 31, 32, 33, 34, 35, 36, 36, 36, 37, 37, 37, 38, 38, 38, 39, 39,
	39, 40, 41, 42, 43, 44, 45)
g.lasso.fit.int <- cv.gglasso(x=X.pred.int, y=Y, group=groups.ints, nfolds=10)

# Screening via distance correlation

X.corr <- X.dat[, -1]

# distance correlations
dcors <- numeric(ncol(X.corr))
for(i in 1:ncol(X.corr)){
	dcors[i] <- dcor(x=X.corr[, i], y=Y)
}

df.dcor <- data.frame(colnames(X.corr), dcors)

X.corr <- X.corr[, !(colnames(X.corr) == "rurality")]
# Pearson correlations
pcors <- numeric(ncol(X.corr))
for(i in 1:ncol(X.corr)){
	# pcors[i] <- corr(matrix(X.corr[, i], Y))
	pcors[i] <- corr(cbind(X.corr[, i], Y))
}

df.pcor <- data.frame(colnames(X.corr), pcors)

# Because of distance correaltions, it looks like ARsenic may have a nonlinear
# relationship with response. Try GAM with Arsenic, Nitrates, pct.agricultural, earnings,
# pct.over.65

# First scale data

for(i in 1:ncol(data.ggplot)){
	if(is.numeric(data.ggplot[, i])){
		data.ggplot[, i] <- scale(data.ggplot[, i])
	}
}

# data.ggplot <- scale(data.ggplot)

# gam.full <- gam(Y ~., data=data.ggplot)

data.gam <- data.frame(data.ggplot[c("Arsenic", "Nitrates", "pct.agricultural",
	"earnings", "pct.over.65", "rurality")], Y)

gam.model.1 <- gam(Y ~., data=data.gam)

data.gam.2 <- data.frame(data.ggplot[c("Arsenic", "Nitrates", "Uranium",
	"earnings", "pct.over.65")], Y)

gam.model.2 <- gam(Y ~., data=data.gam.2)

gam.model.ints <- gam(Y ~ Arsenic + Nitrates + Uranium + earnings + pct.over.65
	+ Arsenic:Uranium + Nitrates:Uranium + Nitrates:Arsenic, data=data.ggplot)

mses <- c(mses, 
	# mse(Y, predict(gam.full)), 
	mse(Y, predict(gam.model.1)), 
	mse(Y, predict(gam.model.2)),
	mse(Y, predict(gam.model.ints))
	)
mse.labels <- c(mse.labels, 
	# "gam.full", 
	"gam.model.1", 
	"gam.model.2",
	"gam.model.ints"
	)

# Also try random forest

# rf.full <- randomForest(Y ~., data=data.ggplot)


rf.model.1 <- randomForest(Y ~., data=data.gam)


rf.model.2 <- randomForest(Y ~., data=data.gam.2)

mses <- c(mses,
	# mse(Y, rf.full$predicted),
	mse(Y, rf.model.1$predicted), 
	mse(Y, rf.model.2$predicted)
	)

mse.labels <- c(mse.labels, 
	# "rf.full", 
	"rf.model.1", 
	"rf.model.2"
	)

# Compare MSE of OLS< lasso, gam, randomForest

df.mse <- data.frame(mse.labels, mses)
