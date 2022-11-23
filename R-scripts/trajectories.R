################################################################
#   BIOME project
#   Berte e clorofilla
#
# 
# GPL (C) Clara Tattoni started 16/11/2022 
#
##########################################################

# load libs and set wd
library (plyr) ## relevel and other nice stuff with tables
#library(adehabitatLT) #animal movement
##library(chron) # time handling
#library(spatstat) #not sure I need it
library(move)
library(recurse)
library(scales)
library(sp)
library(bayesmove) #prepare data in one command
library(ggplot2)

setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )

#load data

yelkouan <- read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/berta_minore_class_UTM.csv")
#https://rdrr.io/cran/bayesmove/man/prep_data.html


yelkouan <- na.omit(yelkouan)
yelkouan$date <- as.POSIXct(yelkouan$timestamp)
yelkouan$device_id <- as.factor(yelkouan$device_id)
yelkouan$birds_activity1 <- as.factor(yelkouan$birds_activity1)
yelkouan$birds_activity2 <- as.factor(yelkouan$birds_activity2)
#calculate step lengths and turning angles
tracks <- prep_data(dat = yelkouan, coord.names =  c("xcoord","ycoord"), id = "device_id")

#summary

summary(tracks)

tracks <- na.omit(tracks)
#col: step length (step), 
#turning angle (angle), 
#net-squared displacement (NSD), 
#and time step (dt). 

#remove odd step
tracks <-tracks[tracks$step < 10000 ,  ]
#remove dt too long (1o min)

tracks <-tracks[tracks$dt < 1000 ,  ]

############### EDA  #############################
#explore step length to find best radius ########################

summary(tracks$step)

plot(density(tracks$step))
hist(tracks$step, xlab="Step lenght", main="P. Yelkouan")

hist(tracks[tracks$birds_activity1=="F",]$step, xlab="Step lenght", main="Feeding 1")
hist(tracks[tracks$birds_activity1=="T",]$step, xlab="Step lenght", main="Travelling 1")
hist(tracks[tracks$birds_activity1=="R",]$step, xlab="Step lenght", main="Resting 1")


hist(tracks[tracks$birds_activity2=="F",]$step, xlab="Step lenght", main="Feeding 2")
hist(tracks[tracks$birds_activity2=="T",]$step, xlab="Step lenght", main="Travelling 2")
hist(tracks[tracks$birds_activity2=="R",]$step, xlab="Step lenght", main="Resting 2")


boxplot(tracks$step ~tracks$device_id, ylim=c(0,3000), xlab="GPS id", main="Flight lenght", ylab="lenght m")


boxplot(tracks$step ~tracks$birds_activity1, ylim=c(0,10000), xlab="Activity", main="Birds activity 1", ylab="lenght m")
boxplot(tracks$step ~tracks$birds_activity2, ylim=c(0,8000), xlab="Activity", main="Birds activity 2", ylab="lenght m")

ggplot(tracks, aes(birds_activity2,step, fill=birds_activity2))+geom_boxplot()
ggplot(tracks, aes(birds_activity1,step, fill=birds_activity1))+geom_boxplot()
ggplot(tracks, aes(step, fill=birds_activity1))+geom_histogram()
ggplot(tracks, aes(step, fill=birds_activity2))+geom_histogram()
ggplot(tracks, aes(birds_activity1,Speed_m_s, fill=birds_activity1))+geom_boxplot()
ggplot(tracks, aes(birds_activity2,Speed_m_s, fill=birds_activity2))+geom_boxplot()
ggplot(tracks, aes(birds_activity1,angle, fill=birds_activity1))+geom_boxplot()
ggplot(tracks, aes(birds_activity2,angle, fill=birds_activity2))+geom_boxplot()
ggplot(tracks, aes(device_id,Speed_m_s, fill=birds_activity2))+geom_boxplot()+facet_wrap(tracks$birds_activity2)
ggplot(tracks, aes(device_id,Speed_m_s, fill=birds_activity1))+geom_boxplot()+facet_grid(tracks$birds_activity1)


tapply(tracks$step, tracks$birds_activity1, mean)
tapply(tracks$step, tracks$birds_activity2, mean)

#Take birds activity 2 for step lenght

#radius 560 m





#                   REVISITING ANALYSYS ##################
library(recurse)
library(scales)
library(sp)
library(fields)



#Recourse analysys of P. Yelkuan
#https://cran.r-project.org/web/packages/recurse/vignettes/recurse.html
#21/11/2022

#FIXME create a move object from data
#For a data frame, the trajectory data with four columns (the x-coordinate, the y-coordinate, the datetime, and the animal id).

berte <- tracks[,c( "x", "y","date","device_id")] 

plot(tracks$x, tracks$y, col = tracks$birds_activity2, pch = 20, 
     xlab = "x", ylab = "y", asp = 1)
#The recurse object returned by the getRecursions() 
#function contains a vector the same length as the data with the
#number of revisitations for each location. One way this data can be visualized is spatially.

#Radius tested 
#radius 560 m mean
# radius 1000 m 1-4-60 visits 
# 2000 chrash
visit = getRecursions(berte, 2000) 

par(mfrow = c(1, 1), mar = c(4, 4, 1, 1))
plot(visit, berte, legendPos = c(10000, 4200000) 
     ,xlim=c(0,1000000), ylim=c(4200000,4800000),
     )

hist(visit$revisits, breaks = 100, main = "", xlab = "Revisits (radius = 500)")
summary(visit$revisits)
head(visit$revisitStats)
summary(visit$revisitStats)

par(mfrow = c(1, 1), mar = c(4, 4, 1, 1))
plot(visit, berte, legendPos = c(0,3000000 ))


#########Multiple individuals ############

#Suppose we have tagging data from another individual, wren, released at the same 
#time and location as martin. Here we plot martin in red and wren in dark blue.
par(mfrow = c(1, 1))
data(wren)
animals = rbind(martin, wren)
plot(animals$x, animals$y, col = c("red", "darkblue")[as.numeric(animals$id)], 
     pch = ".", xlab = "x", ylab = "y", asp = 1)

popvisit = getRecursions(animals, 2) 

head(popvisit$revisitStats)

plot(popvisit, animals, legendPos = c(15, -10))
#visit as specific locations
locations = data.frame(x = c(0, 10, 20), y = c(0, 10, 10))
locvisit = getRecursionsAtLocations(wren, locations, 2) 

locvisit$revisits

#If specific locations are not known a priori, 
#they can also be identified from the recursion analysis using clustering.

visitThreshold = quantile(popvisit$revisits, 0.8)
popCluster = kmeans(animals[popvisit$revisits > visitThreshold,c("x", "y")], centers = 3)

plot(animals$x, animals$y, col = c("red", "darkblue")[as.numeric(animals$id)], 
     pch = ".", xlab = "x", ylab = "y", asp = 1)
with(animals[popvisit$revisits > visitThreshold,],
     points(x, y, col = c(alpha("red", 0.5), alpha("darkblue", 0.5))[as.numeric(id)], 
            pch = c(15:17)[popCluster$cluster]) )
legend("topleft", pch = 15:17, legend = paste("cluster", 1:3), bty = "n")


#. For example, we may be interesting in comparing residence times 
#between the first and second halves of martin’s trajectory.

breaks = martin$t[c(1, nrow(martin)/2, nrow(martin))]
beforeAfterResTime = calculateIntervalResidenceTime(martinvisit, breaks = breaks, 
                                                    labels = c("before", "after"))

head(beforeAfterResTime)


#see also https://cran.r-project.org/web/packages/move/vignettes/move.html#import-non-movebank-data

################## FIXME #########################################################
#duplicated time stamps
n_occur <- data.frame(table(yelkouan$timestamp))
n_occur[n_occur$Freq > 1,]

#tells you which ids occurred more than once.

yelkouan[yelkouan$timestamp %in% n_occur$Var1[n_occur$Freq > 1],]


yelkouan2 <- move(x=yelkouan$xcoord, y=yelkouan$ycoord, 
                  removeDuplicatedTimestamps=TRUE,
                time=yelkouan$date, 
                proj=CRS("+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m"), 
                data=yelkouan, animal=yelkouan$device_id, sensor="GPS"
               )
  
projection(yelkouan2)



plot(yelkouan2, xlab="Longitude", ylab="Latitude", type="l", pch=16, lwd=0.5)
points(yelkouan, pch=20, cex=0.5)
