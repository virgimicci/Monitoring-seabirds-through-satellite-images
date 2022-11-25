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
library(move)
library(recurse) #activity analysis
library(scales)
library(sp)
library(bayesmove) #prepare movement data in one command
library(ggplot2)

setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )

#load data P. yelkouan

yelkouan <- read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/berta_minore_class_UTM.csv")
#https://rdrr.io/cran/bayesmove/man/prep_data.html


yelkouan <- na.omit(yelkouan)
yelkouan$date <- as.POSIXct(yelkouan$timestamp)
yelkouan$device_id <- as.factor(yelkouan$device_id)
yelkouan$birds_activity1 <- as.factor(yelkouan$birds_activity1)
yelkouan$birds_activity2 <- as.factor(yelkouan$birds_activity2)
yelkouan$Tortuosity <- "T>0.98" 
yelkouan[yelkouan$tortuosity.index <0.98,  ]$Tortuosity <- "T<0.98" 
yelkouan$Tortuosity <- as.factor(yelkouan$Tortuosity)
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
#remove dt too long (1o min) or too short

tracks <-tracks[tracks$dt < 1000 ,  ]

tracks <-tracks[tracks$dt != 0 ,  ]


#load data with EMbc classification
EMbC <- read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/Classified df/Puffinus yelkouan_EMbC.csv")

EMbC$date <- as.POSIXct(EMbC$timestamp)

EMbC <- EMbC[,-c(1,2)]

a <- join(tracks, EMbC, by="date", type= "left")

summary(a)
#remove duplicate fields
a <- a[,-c(17:21)]
tracks <- a
tracks$EMbC_classif <- as.factor(tracks$EMbC_classif)
############### EDA  #############################
#explore step length to find best radius ########################

summary(tracks)
summary(tracks$step)

plot(density(tracks$step))
hist(tracks$step,  xlab="Step length (m)", main="P. Yelkouan")

hist(tracks[tracks$birds_activity1=="F",]$step, xlab="Step length(m)", main="Feeding 1")
hist(tracks[tracks$birds_activity1=="T",]$step, xlab="Step length(m)", main="Travelling 1")
hist(tracks[tracks$birds_activity1=="R",]$step, xlab="Step length(m)t", main="Resting 1")


hist(tracks[tracks$birds_activity2=="F",]$step, xlab="Step lenght (m)", main="Feeding 2")
hist(tracks[tracks$birds_activity2=="T",]$step, xlab="Step lenght(m)", main="Travelling 2")
hist(tracks[tracks$birds_activity2=="R",]$step, xlab="Step lenght(m)", main="Resting 2")


boxplot(tracks$step ~tracks$device_id, ylim=c(0,3000), xlab="GPS id", main="Flight lenght", ylab="lenght m")
#boxplot(tracks$step ~tracks$birds_activity1, ylim=c(0,10000), xlab="Activity", main="Birds activity 1", ylab="lenght m")
#boxplot(tracks$step ~tracks$birds_activity2, ylim=c(0,8000), xlab="Activity", main="Birds activity 2", ylab="lenght m")

ggplot(tracks, aes(birds_activity2,step, fill=birds_activity2))+geom_boxplot()+ylab("Step length(m)" )
ggplot(tracks, aes(birds_activity1,step, fill=birds_activity1))+geom_boxplot()+ylab("Step length(m)" )
ggplot(tracks, aes(EMbC_classif,step, fill=EMbC_classif))+geom_boxplot()+ylab("Step length(m)" )

#ggplot(tracks, aes(step, fill=birds_activity1))+geom_histogram()+facet_grid(tracks$birds_activity1)
#ggplot(tracks, aes(step, fill=birds_activity2))+geom_histogram()+facet_grid(tracks$birds_activity2)
#ggplot(tracks, aes(step, fill=EMbC_classif))+geom_histogram()+facet_grid(tracks$birds_activity2)

ggplot(tracks, aes(birds_activity1,Speed_m_s, fill=birds_activity1))+geom_boxplot()
ggplot(tracks, aes(birds_activity2,Speed_m_s, fill=birds_activity2))+geom_boxplot()
ggplot(tracks, aes(birds_activity1,angle, fill=birds_activity1))+geom_boxplot()
ggplot(tracks, aes(birds_activity2,angle, fill=birds_activity2))+geom_boxplot()
ggplot(tracks, aes(birds_activity1,Speed_m_s, fill=birds_activity1))+geom_boxplot()+facet_grid(tracks$Tortuosity)
ggplot(tracks, aes(birds_activity2,Speed_m_s, fill=birds_activity2))+geom_boxplot()+facet_grid(tracks$Tortuosity)

ggplot(tracks, aes(birds_activity1,Speed_m_s, fill=EMbC_classif))+geom_boxplot()
ggplot(tracks, aes(birds_activity2,Speed_m_s, fill=EMbC_classif))+geom_boxplot()

#COnfronto EMBC Birdss activity1/2 ##############
ggplot(tracks, aes(EMbC_classif, fill=birds_activity2))+geom_bar()+ggtitle(" EMbC vs Birds activity2")
ggplot(tracks, aes(EMbC_classif, fill=birds_activity1))+geom_bar()+ggtitle(" EMbC vs Birds activity 1")
ggplot(tracks, aes(birds_activity1, fill=birds_activity2))+geom_bar()+ggtitle("Birds activity 1 vs 2")

#ggplot(tracks, aes(device_id,Speed_m_s, fill=birds_activity2))+geom_boxplot()+facet_wrap(tracks$birds_activity2)
#ggplot(tracks, aes(device_id,Speed_m_s, fill=birds_activity1))+geom_boxplot()+facet_grid(tracks$birds_activity1)


tapply(tracks$step, tracks$birds_activity1, mean)
tapply(tracks$step, tracks$birds_activity1, sd)
tapply(tracks$step, tracks$birds_activity2, mean)
tapply(tracks$step, tracks$birds_activity2, sd)
tapply(tracks$step, tracks$EMbC_classif, mean)
tapply(tracks$step, tracks$EMbC_classif, sd)
#Take birds activity 2 for step lenght

#radius 560 m

#                   REVISITING ANALYSYS ##################
library(recurse)
library(scales)
library(sp)
library(fields) #per grafici

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

#Radius tested #############
#radius 560 m mean
# radius 1000 m 1-4-60 visits 
# 2000 chrash
#TODO split analysis in 3 by individuals
 # Greco a parte 220675_MCR_art15
 #Corsica a parte 220679_MCR_m e 220685_MCR_n 
 # Golfo Leone  all the rest


####### Grecia #####

greek <- berte[berte$device_id=="220675_MCR_art15",]
summary(greek)


tapply(greek$step, greek$birds_activity1, mean)
tapply(greek$step, greek$birds_activity2, mean)

visit = getRecursions(greek, 2000) 

par(mfrow = c(1, 1), mar = c(4, 4, 1, 1))
plot(visit, greek, legendPos = c(500000, 4200000) , main="Greek"
     #,xlim=c(0,1000000), ylim=c(4200000,4800000),
)

hist(visit$revisits, breaks = 100, main = "", xlab = "Revisits (radius = 500)")
summary(visit$revisits)
head(visit$revisitStats)
tail(visit$revisitStats)
summary(visit$revisitStats)

greek_visit_2000 <-visit
#Tested radii 500, 100, 2000, 3000 max visits 11, 12, 13, 11

x<-as.data.frame(greek_visit_2000$revisitStats)
write.csv(x, "Greek_visit_2000.csv")

x<-as.data.frame(greek_visit_1000$revisitStats)
write.csv(x, "Greek_visit_1000.csv")

####### Corsica #####

corse <- berte[berte$device_id %in% c("220679_MCR_m","220685_MCR_n") ,]
summary(corse)


#tapply(corse$step, corse$birds_activity1, mean)
#tapply(corse$step, corse$birds_activity2, mean)

visit = getRecursions(corse, 3000) 


plot(visit, corse, legendPos = c(200000, 4500000) , main="Corse"
     #,xlim=c(0,1000000), ylim=c(4200000,4800000),
)

hist(visit$revisits, breaks = 100, main = "", xlab = "Revisits (radius = 500)")
summary(visit$revisits)
head(visit$revisitStats)

summary(visit$revisitStats)


#Tested radii 1000, 2000, 3000 max visits 12, 16,12

x<-as.data.frame(visit$revisitStats)
write.csv(x, "Corse_visit_2000.csv")


visitThreshold = quantile(visit$revisits, 0.8)


####### Golfo Lyone ################
#TODO remove Greece and Corse

berte1 <- berte[!(berte$device_id %in%  c("220679_MCR_m","220685_MCR_n","220675_MCR_art15")) ,]
visit = getRecursions(berte1, 2000) 


plot(visit, berte1, legendPos = c(10000, 4500000) 
     #,xlim=c(0,1000000), ylim=c(4200000,4800000),
     , main="Golfo"
     )

hist(visit$revisits, breaks = 100, main = "", xlab = "Revisits (radius = 2000)")
summary(visit$revisits)
head(visit$revisitStats)
summary(visit$revisitStats)



#Tested radii 1000, 2000, 3000 max visits 12, 16,12

x<-as.data.frame(visit$revisitStats)
write.csv(x, "Berte1_visit_2000.csv")


visitThreshold = quantile(visit$revisits, 0.8)

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
