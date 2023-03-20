################################################################
#   BIOME project
#   Berte e clorofilla
#
# 
# GPL (C) Clara Tattoni started 16/11/2022 
# V.2 compare methods with update classification 19/3/2023
##########################################################

# load libs and set wd
library (plyr) ## relevel and other nice stuff with tables
library (dplyr)
library(move)
library(recurse) #activity analysis
library(scales)
library(sp)
library(bayesmove) #prepare movement data in one command
library(ggplot2)
library(fields) #per grafici tracce

setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )

#load data
#Yelkouan shearwater Berta minore
#P. yelkouan  #############################


#https://rdrr.io/cran/bayesmove/man/prep_data.html

#yelkouan <-  read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/Classified df/Puffin_yelk_EMbC_activity12.csv")
#FIXED
yelkouan <- read.csv("Data/Classified df/Puffin_yelk_NEW_utm.csv")

#yelkouan <- na.omit(yelkouan)
yelkouan$date <- as.POSIXct(yelkouan$timestamp)
yelkouan$device_id <- as.factor(yelkouan$device_id)
yelkouan$Pezzo <- as.factor(yelkouan$Pezzo_clas)
yelkouan$Meier <- as.factor(yelkouan$Meier_clas)

yelkouan$Revisit <- "Low usage"
yelkouan[yelkouan$Revisit_c!="Other",]$Revisit <- "High usage"

yelkouan$Revisit <- as.factor(yelkouan$Revisit)
#yelkouan$Tortuosity <- "T>0.98" 
#yelkouan[yelkouan$tortuosity.index <0.98,  ]$Tortuosity <- "T<0.98" 
#yelkouan$Tortuosity <- as.factor(yelkouan$Tortuosity)


#EMBC reclass
# 1- Low/Low = Rest
# 2- Low/High = Forage
# 3- High/Low = Travel
# 4- High/High = Active search for food

yelkouan$EMBC <- "R"
yelkouan[yelkouan$EMbC_class== 1, ]$EMBC <- "R"
yelkouan[yelkouan$EMbC_class== 2, ]$EMBC <- "F"
yelkouan[yelkouan$EMbC_class== 3, ]$EMBC <- "T"
yelkouan[yelkouan$EMbC_class== 4, ]$EMBC <- "AF"

yelkouan$EMBC <- as.factor(yelkouan$EMBC)



#calculate step lengths and turning angles
tracks <- prep_data(dat = yelkouan, coord.names =  c("xcoord","ycoord"), id = "device_id")

#summary
summary(tracks)
tracks <- tracks[!is.na(tracks$dt),]
#col: step length (step), 
#turning angle (angle), 
#net-squared displacement (NSD), 
#and time step (dt). 

#remove odd step
tracks <-tracks[tracks$step < 10000 ,  ]
#remove dt too long (1o min) or too short

tracks <-tracks[tracks$dt < 1000 ,  ]

tracks <-tracks[tracks$dt != 0 ,  ]


############### EDA  #############################
#explore step length to find best radius ########################

summary(tracks)
summary(tracks$step)

plot(density(tracks$step))
hist(tracks$step,  xlab="Step length (m)", main="P. Yelkouan")

hist(tracks[tracks$Pezzo=="F",]$step, xlab="Step length(m)", main="Feeding 1")
hist(tracks[tracks$Pezzo=="T",]$step, xlab="Step length(m)", main="Travelling 1")
hist(tracks[tracks$Pezzo=="R",]$step, xlab="Step length(m)t", main="Resting 1")


hist(tracks[tracks$Meier=="F",]$step, xlab="Step lenght (m)", main="Feeding 2")
hist(tracks[tracks$Meier=="T",]$step, xlab="Step lenght(m)", main="Travelling 2")
hist(tracks[tracks$Meier=="R",]$step, xlab="Step lenght(m)", main="Resting 2")


#boxplot(tracks$step ~tracks$device_id, ylim=c(0,3000), xlab="GPS id", main="Flight lenght", ylab="lenght m")
#boxplot(tracks$step ~tracks$Pezzo, ylim=c(0,10000), xlab="Activity", main="Step lenght", ylab="lenght m")
#boxplot(tracks$step ~tracks$Meier, ylim=c(0,8000), xlab="Activity", main="Birds activity 2", ylab="lenght m")

ggplot(tracks, aes(Meier,step, fill=Meier))+geom_boxplot()+ylab("Step length(m)" )
ggplot(tracks, aes(Pezzo,step, fill=Pezzo))+geom_boxplot()+ylab("Step length(m)" )
ggplot(tracks, aes(EMBC,step, fill=EMBC))+geom_boxplot()+ylab("Step length(m)" )
ggplot(tracks, aes(Revisit,step, fill=Revisit))+geom_boxplot()+ylab("Step length(m)" )


ggplot(tracks, aes(Pezzo,Speed_m.s, fill=Pezzo))+geom_boxplot()
ggplot(tracks, aes(Meier,Speed_m.s, fill=Meier))+geom_boxplot()
ggplot(tracks, aes(EMBC,Speed_m.s, fill=EMBC))+geom_boxplot()
ggplot(tracks, aes(Revisit,Speed_m.s, fill=Revisit))+geom_boxplot()


ggplot(tracks, aes(Pezzo,angle, fill=Pezzo))+geom_boxplot()
ggplot(tracks, aes(Meier,angle, fill=Meier))+geom_boxplot()
ggplot(tracks, aes(Pezzo,Speed_m.s, fill=Pezzo))+geom_boxplot()
ggplot(tracks, aes(Meier,Speed_m.s, fill=Meier))+geom_boxplot()#+facet_grid(tracks$Tortuosity)

ggplot(tracks, aes(Pezzo,Speed_m.s, fill=EMBC))+geom_boxplot()
ggplot(tracks, aes(Meier,Speed_m.s, fill=EMBC))+geom_boxplot()

#COnfronto EMBC pezzo and Meier ##############
ggplot(tracks, aes(EMBC, fill=Meier))+geom_bar()+ggtitle(" EMbC vs Meier")
ggplot(tracks, aes(EMBC, fill=Pezzo))+geom_bar()+ggtitle(" EMbC vs Pezzo")
ggplot(tracks, aes(Pezzo, fill=Meier))+geom_bar()+ggtitle("Pezzo vs Meier")
#ggplot(tracks, aes(Revisit, fill=Meier))+geom_bar()+ggtitle("Revisit vs Meier")

#ggplot(tracks, aes(device_id,Speed_m.s, fill=Meier))+geom_boxplot()+facet_wrap(tracks$Meier)
#ggplot(tracks, aes(device_id,Speed_m.s, fill=Pezzo))+geom_boxplot()+facet_grid(tracks$Pezzo)


tapply(tracks$step, tracks$Pezzo, mean)
tapply(tracks$step, tracks$Pezzo, sd)
tapply(tracks$step, tracks$Meier, mean)
tapply(tracks$step, tracks$Meier, sd)
tapply(tracks$step, tracks$EMBC, mean)
tapply(tracks$step, tracks$EMBC, sd)

tracks %>%
  group_by(EMBC) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))

tracks %>%
  group_by(Pezzo) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))

tracks %>%
  group_by(Meier) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))


######################################################################

#Calonectris diomedea                    #############################
# Berta maggiore - Scopoli's shearwater 

########################################################################

#FIXME OLD CLASSIFICATION
#load data wuth all classifications
#berta_EMbC <- read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/Classified df/Calonectris diomedea_EMbC_activity12.csv")
cd_MODIS <- read.csv("Data/Classified df/Calonec_diom_NEW_utm.csv")
summary(cd_MODIS)

#cd_MODIS <- na.omit(cd_MODIS)
cd_MODIS$date <- as.POSIXct(cd_MODIS$timestamp)
cd_MODIS$device_id <- as.factor(cd_MODIS$device_id)
cd_MODIS$Distance <-cd_MODIS$distance*78 #convert degrees to km


#classify Embc
# 1- Low/Low = Rest
# 2- Low/High = Forage
# 3- High/Low = Travel
# 4- High/High = Active search for food

cd_MODIS $EMBC <- "R"
cd_MODIS [cd_MODIS $EMbC== 1, ]$EMBC <- "R"
cd_MODIS [cd_MODIS $EMbC== 2, ]$EMBC <- "F"
cd_MODIS [cd_MODIS $EMbC== 3, ]$EMBC <- "T"
cd_MODIS [cd_MODIS $EMbC== 4, ]$EMBC <- "AF"
cd_MODIS $EMBC <- as.factor(cd_MODIS $EMBC)


cd_MODIS $Pezzo <- as.factor(cd_MODIS $Pezzo)
cd_MODIS $Meier <- as.factor(cd_MODIS $Meier)

cd_MODIS$Revisit <- "Low usage"
cd_MODIS[cd_MODIS$revisit=="Feeding",]$Revisit <- "High usage"
table(cd_MODIS$Pezzo)
table(cd_MODIS$Meier)
table(cd_MODIS$EMBC)
table(cd_MODIS$revisit)
table(cd_MODIS$Revisit)
#calculate step lengths and turning angles
tracks_berta <- prep_data(dat = cd_MODIS, coord.names =  c("xcoord","ycoord"), id = "device_id")

#summary
summary(tracks_berta)
tracks_berta <- tracks_berta[!is.na(tracks_berta$dt),]
#tracks_berta <- na.omit(tracks_berta)
#col: step length (step), 
#turning angle (angle), 
#net-squared displacement (NSD), 
#and time step (dt). 

#remove odd steps
tracks_berta <-tracks_berta[tracks_berta$step <10000,  ]

#remove dt too long (1o min) or too short
tracks_berta <-tracks_berta[tracks_berta$dt != 0 ,  ]
tracks_berta <-tracks_berta[tracks_berta$dt > 0 ,  ]
tracks_berta <-tracks_berta[tracks_berta$dt < 1000 ,  ]

summary(tracks_berta)


############### EDA  #############################
#explore step length to find best radius ########################

summary(tracks_berta$step)
plot(density(tracks_berta$step))


ggplot(tracks_berta, aes(Meier,step, fill=Meier))+geom_boxplot()+ylab("Step length(m)" )+ggtitle("Meier")
ggplot(tracks_berta, aes(Pezzo,step, fill=Pezzo))+geom_boxplot()+ylab("Step length(m)" )+ggtitle("Pezzo")
ggplot(tracks_berta, aes(EMBC,step, fill=EMBC))+geom_boxplot()+ylab("Step length(m)" )+ggtitle("EMBC")
ggplot(tracks_berta, aes(Revisit,step, fill=Revisit))+geom_boxplot()+ylab("Step length(m)" )+ggtitle("Recourse")

#ggplot(tracks_berta, aes(step, fill=Pezzo))+geom_histogram()+facet_grid(tracks_berta$Pezzo)
##ggplot(tracks_berta, aes(step, fill=Meier))+geom_histogram()+facet_grid(tracks_berta$Meier)
#ggplot(tracks_berta, aes(step, fill=EMbC_class))+geom_histogram()+facet_grid(tracks_berta$Meier)

ggplot(tracks_berta, aes(Pezzo,Speed_m.s, fill=Pezzo))+geom_boxplot()+ggtitle("Pezzo")
ggplot(tracks_berta, aes(Meier,Speed_m.s, fill=Meier))+geom_boxplot()+ggtitle("Meier")
ggplot(tracks_berta, aes(EMBC,Speed_m.s, fill=EMBC))+geom_boxplot()+ggtitle("EMBC")
ggplot(tracks_berta, aes(Revisit,Speed_m.s, fill=EMBC))+geom_boxplot()+ggtitle("Recourse")

#COnfronto EMBC Birdss activity1/2 ##############
ggplot(tracks_berta, aes(EMBC, fill=Meier))+geom_bar()+ggtitle(" EMbC vs Meier")
ggplot(tracks_berta, aes(EMBC, fill=Pezzo))+geom_bar()+ggtitle(" EMbC vs Pezzo")
ggplot(tracks_berta, aes(Pezzo, fill=Meier))+geom_bar()+ggtitle("Pezzo vs Meier")



tracks_berta %>%
  group_by(EMBC) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))

tracks_berta %>%
  group_by(Pezzo) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))

tracks_berta %>%
  group_by(Meier) %>%
  dplyr::summarize(Mean = mean(step, na.rm=TRUE), SD= sd(step))


