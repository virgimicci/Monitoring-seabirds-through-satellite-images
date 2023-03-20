################################################################
#   BIOME project
#   Berte e clorofilla
#
# 
# GPL (C) Clara Tattoni started 15/03/2023 
#
#
#  EDA and modelling of the relationship between feeding and Chla
##########################################################


# load libs and set wd -----------
library (plyr) ## relevel and other nice stuff with tables
library (dplyr)
#library(sp)
library(ggplot2)
#library(sf) #create objects to map
#library(mapview) #for nice map viewing
library(lubridate)
setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )

#load data with classification and sample
#Yelkouan shearwater Berta minore
#P. yelkouan  #############################

#py_MODIS <- read.csv("Data/Classified df/Puffin_yelk_NEW_utm.csv")
py_MODIS <- read.csv("/home/clara/lavori/biome/dati/py_MODIS21.CSV")

summary(py_MODIS)

#datasetup

py_MODIS$hour <- hour(py_MODIS$timestamp)
py_MODIS$hour <-as.factor(py_MODIS$hour)
summary(py_MODIS$hour)

py_MODIS$month <- month(py_MODIS$timestamp)
py_MODIS$month <-as.factor(py_MODIS$month)
summary(py_MODIS$month)

py_MODIS$device_id <- as.factor(py_MODIS$device_id)

py_MODIS <-py_MODIS[py_MODIS$Pezzo_clas!="",]
py_MODIS$Pezzo <- as.factor(py_MODIS$Pezzo_clas)
py_MODIS$Meier <- as.factor(py_MODIS$Meier_clas)

py_MODIS$Revisit <- "Low usage"
py_MODIS[py_MODIS$Revisit_c!="Other",]$Revisit <- "High usage"
py_MODIS$Revisit <- as.factor(py_MODIS$Revisit)

py_MODIS$EMBC <- "R"
py_MODIS[py_MODIS$EMbC_class== 1, ]$EMBC <- "R"
py_MODIS[py_MODIS$EMbC_class== 2, ]$EMBC <- "F"
py_MODIS[py_MODIS$EMbC_class== 3, ]$EMBC <- "T"
py_MODIS[py_MODIS$EMbC_class== 4, ]$EMBC <- "AF"

py_MODIS$EMBC <- as.factor(py_MODIS$EMBC)

#remove points on land

#py_MODIS <- py_MODIS[py_MODIS$distance>0,]


#Create a column with chla anomaly for the right month
#FIXME UPDATE AN0MALY IN GEE
py_MODIS$Chla_anomaly <- 0

py_MODIS[py_MODIS$month==3,]$Chla_anomaly <- py_MODIS[py_MODIS$month==3,]$MODIS3
py_MODIS[py_MODIS$month==4,]$Chla_anomaly <- py_MODIS[py_MODIS$month==4,]$MODIS4
py_MODIS[py_MODIS$month==5,]$Chla_anomaly <- py_MODIS[py_MODIS$month==5,]$MODIS5
summary(py_MODIS$Chla_anomaly  )

#Remove NA
py_MODIS <-py_MODIS[!is.na(py_MODIS$Chla_anomaly),] 
summary(py_MODIS)

## graphic EDA MODIS  ---------
#var distribution
plot(density(py_MODIS$Distance))
plot(table(py_MODIS$hour))
plot(table(py_MODIS$month))
plot(table(py_MODIS$Revisit))
plot(density(py_MODIS$Visit_n))
plot(density(py_MODIS$Chla_anomaly))

### Recourse activity patterns -----------

a <-ggplot(py_MODIS, aes(x=as.numeric(hour), fill= Revisit)) 

a+  geom_bar(stat = "count",position = "dodge")

a + geom_density(aes(y = ..count..)) + xlab("hour")+#xlim(0,23)+
  facet_wrap(py_MODIS$Revisit)+ggtitle("Recourse Analisys")

# done with all data , does not change 
ggplot(py_MODIS, aes(x=month, fill= Revisit)) +
  geom_bar(stat = "count",position = "dodge")+ggtitle("Recourse Analisys")
#MODIS and activity

ggplot(py_MODIS, aes(x=Revisit,  y=Chla_anomaly)) + #ylim(0,0.2)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse Analisys")
#no pattern

ggplot(py_MODIS[py_MODIS$Visit_n<40,], aes(x=Visit_n,  y=Chla_anomaly)) +
  geom_smooth() +  xlab("N of Revisits") + ggtitle("Recourse Analisys")
#????

#Chl_average

ggplot(py_MODIS, aes(x=Revisit,  y=chl_mean_20y,fill=Revisit)) + ylab("Avg Chl-a 2002-2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse-MODIS Chl AVg2002-2021")

#FIXME log or not log
ggplot(py_MODIS, aes(x=Revisit,  y=log(chl_mean2021),fill=Revisit)) + ylab("Avg Chl-a 2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse-MODIS ")

#ggplot(py_MODIS[py_MODIS$Visit_n,], aes(x=Visit_n,  y=chl_mean2021)) +
#  geom_smooth() +  xlab("N of Revisits") + ggtitle("Recourse Analisys-MODIS ")


### EMBC -----------

b <-ggplot(py_MODIS, aes(x=as.numeric(hour), fill= EMBC)) 

b + geom_density() +facet_wrap(py_MODIS$EMBC)+ggtitle("EMBC classification")+xlab("hour")

ggplot(py_MODIS, aes(x=EMBC,  y=Chla_anomaly)) +# ylim(0,0.2)+
  geom_boxplot()+ggtitle("EMBC")

#no pattern
ggplot(py_MODIS, aes(x=birds_ac_1,  y=Chla_anomaly)) +# ylim(0,0.2)+
  geom_boxplot()+  xlab("Activity")+ggtitle("Meyer ")
#no pattern

### Meier --------------
m <-ggplot(py_MODIS, aes(x=as.numeric(hour), fill=Meier)) + xlab("hour")

m + geom_density(aes(y = ..count..)) +
  facet_wrap(py_MODIS$Meier)+ggtitle("Meier classification")

#MODIS and activity

ggplot(py_MODIS, aes(x=Meier,  y=Chla_anomaly,fill=Meier)) + 
  geom_boxplot() +
  ylim(0,0.2)+  xlab("Activity")+ggtitle("Meyer")
#no pattern

#Chl_average

ggplot(py_MODIS, aes(x=Meier,  y=chl_mean_20y,fill=Meier)) + ylab("Avg Chl-a 2002-2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2002-2021")


ggplot(py_MODIS, aes(x=Meier,  y=chl_mean2021,fill=Meier)) + ylab("Avg Chl-a 2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2021")


### Pezzo --------------
p <-ggplot(py_MODIS, aes(x=as.numeric(hour), fill=Pezzo)) + xlab("hour")

p + geom_density(aes(y = ..count..)) +
  facet_wrap(py_MODIS$Pezzo)+ggtitle("Pezzo classification")

#MODIS and activity

ggplot(py_MODIS, aes(x=Pezzo,  y=Chla_anomaly,fill=Pezzo)) + 
  geom_boxplot() +
  ylim(0,0.2)+  xlab("Activity")+ggtitle("Pezzo")
#no pattern
rm (a,m,b,p)


#Chl_average

ggplot(py_MODIS, aes(x=Pezzo,  y=chl_mean_20y,fill=Pezzo)) + ylab("Avg Chl-a 2002-2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Pezzo-MODIS avg 2002-2021")


ggplot(py_MODIS, aes(x=Meier,  y=chl_mean2021,fill=Meier)) + ylab("Avg Chl-a 2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2021")

## GLM ------

py_MODIS$revisit2 <- 0
py_MODIS[py_MODIS$Revisit_c=="Feeding", ]$revisit2 <- 1

glm1 <-glm(revisit2~Distance+Chla_anomaly+month, data=py_MODIS, family = "binomial")

summary(glm1)
plot(glm1)

glm2 <-glm(revisit2~Distance+Chla_anomaly, data=py_MODIS, family = "binomial")

summary(glm2)

glm3 <-glm(revisit2~Distance+chl_mean_20y, data=py_MODIS, family = "binomial")

summary(glm3)



## EDA Sentinel 2 ----------------------------------------------
py_S2 <- read.csv("~/lavori/biome/dati/dachiara/py_S2_distance.csv", stringsAsFactors=TRUE)

py_S2$Revisit <-  "Low usage"
py_S2[py_S2$revisit !="Other",]$Revisit <- "High usage"
py_S2$Revisit <- as.factor(py_S2$Revisit)
py_S2$date <-as.POSIXct(py_S2$timestamp)
py_S2$hour <- hour(py_S2$date)
py_S2$hour <-as.factor(py_S2$hour)
summary(py_S2$hour)

py_S2$month <- month(py_S2$date)
py_S2$month <-as.factor(py_S2$month)
#degree to km comversion
py_S2$Distance <- py_S2$distance*78

#var distribution
plot(density(py_S2$Distance))
plot(table(py_S2$hour))
plot(table(py_S2$month))
plot(table(py_S2$revisit))
plot(density(py_S2$Chla))

### Recourse activity patterns -----------


ggplot(py_S2, aes(x=Revisit,  y=log(Chla), fill=Revisit)) +
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse Analisys S2")
# pattern

### EMBC -----------
#FIXME
ggplot(py_S2, aes(x=EMBC,  y=log(Chla))) +# ylim(0,0.2)+
  geom_boxplot()+ggtitle("EMBC")

#no pattern
ggplot(py_S2, aes(x=birds_ac_1,  y=Chla_anomaly)) +# ylim(0,0.2)+
  geom_boxplot()+  xlab("Activity")+ggtitle("Meyer ")
#no pattern

### Meyer --------------

### Pezzo  --------------


## GLM ------

py_S2$revisit2 <- 0
py_S2[py_S2$revisit=="Feeding", ]$revisit2 <- 1

glm1 <-glm(revisit2~Distance+Chla+month, data=py_S2, family = "binomial")

summary(glm1)
plot(glm1)

glm2 <-glm(revisit2~Distance+Chla, data=py_S2, family = "binomial")

summary(glm2)
plot(glm2)


#try join

#FIXME join distance and other Class!
test <-merge(x = py_S2, y = py_MODIS[ , c("fid", "device_id", "EMBC","Pezzo","Meier","Revisit")], by = "fid", all.x=TRUE)
#errors in merge 
table(test$device_id.x,test$device_id.y)
table(test$Revisit.x,test$Revisit.y)

#--------------------------------------------------------------------------------------------

#load data with classification and sample

#Scopoli shearwater Berta maggiore
#C. diomedea  #############################---------------------------------------------

cd_MODIS <- read.csv("~/lavori/biome/dati/cd_distance_from_landMODIS2.csv", stringsAsFactors=TRUE)


summary(cd_MODIS)

#datasetup
cd_MODIS$date <-as.POSIXct(cd_MODIS$timestamp)
cd_MODIS$hour <- hour(cd_MODIS$timestamp)
cd_MODIS$hour <-as.factor(cd_MODIS$hour)
summary(cd_MODIS$hour)

cd_MODIS$month <- month(cd_MODIS$timestamp)
cd_MODIS$month <-as.factor(cd_MODIS$month)
summary(cd_MODIS$month)

#cd_MODIS <- na.omit(cd_MODIS)
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
#remove points on land

cd_MODIS <- cd_MODIS[cd_MODIS$distance>0,]


#Create a column with chla anomaly for the right month

cd_MODIS$Chla_anomaly <- 0

cd_MODIS[cd_MODIS$month==7,]$Chla_anomaly <- cd_MODIS[cd_MODIS$month==7,]$MODIS_Anomnaly_chl_a2020.oct_7
cd_MODIS[cd_MODIS$month==8,]$Chla_anomaly <- cd_MODIS[cd_MODIS$month==8,]$MODIS_Anomnaly_chl_a2020.oct_8
cd_MODIS[cd_MODIS$month==9,]$Chla_anomaly <- cd_MODIS[cd_MODIS$month==9,]$MODIS_Anomnaly_chl_a2020.oct_9
cd_MODIS[cd_MODIS$month==10,]$Chla_anomaly <- cd_MODIS[cd_MODIS$month==10,]$MODIS_Anomnaly_chl_a2020.oct_10
summary(cd_MODIS$Chla_anomaly  )

#Remove NA
cd_MODIS <-cd_MODIS[!is.na(cd_MODIS$Chla_anomaly),] 
summary(cd_MODIS)

## graphic EDA MODIS  ---------
#var distribution
plot(density(cd_MODIS$distance))
plot(table(cd_MODIS$hour))
plot(table(cd_MODIS$month))
plot(table(cd_MODIS$revisit))
plot(density(cd_MODIS$visitIdx))
plot(density(cd_MODIS$Chla_anomaly))

### Recourse activity patterns -----------

a <-ggplot(cd_MODIS, aes(x=as.numeric(hour), fill= Revisit)) 

a+  geom_bar(stat = "count",position = "dodge")

a + geom_density(aes(y = ..count..)) + xlab("hour")+#xlim(0,23)+
  facet_wrap(cd_MODIS$Revisit)+ggtitle("Recourse Analisys")

# done with all data , does not change 
ggplot(cd_MODIS, aes(x=month, fill= Revisit)) +
  geom_bar(stat = "count",position = "dodge")+ggtitle("Recourse Analisys")
#MODIS and activity

ggplot(cd_MODIS, aes(x=Revisit,  y=Chla_anomaly)) + ylim(0,0.2)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse Analisys")
#no pattern

ggplot(cd_MODIS[cd_MODIS$Visit_n<40,], aes(x=Visit_n,  y=Chla_anomaly)) +
  geom_smooth() +  xlab("N of Revisits") + ggtitle("Recourse Analisys")
#????

#Chl_average

ggplot(cd_MODIS, aes(x=Revisit,  y=MODIS_chl_mean_2002_2021,fill=Revisit)) + ylab("Avg Chl-a 2002-2021")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse-MODIS Chl AVg2002-2021")

#FIXME log or not log
ggplot(cd_MODIS, aes(x=Revisit,  y=(chl_mean2020),fill=Revisit)) + ylab("Avg Chl-a 2020")+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse-MODIS mean 2020 ")

#ggplot(cd_MODIS[cd_MODIS$Visit_n,], aes(x=Visit_n,  y=chl_mean2021)) +
#  geom_smooth() +  xlab("N of Revisits") + ggtitle("Recourse Analisys-MODIS ")


### EMBC -----------

b <-ggplot(cd_MODIS, aes(x=as.numeric(hour), fill= EMBC)) 

b + geom_density() +facet_wrap(cd_MODIS$EMBC)+ggtitle("EMBC classification")+xlab("hour")

ggplot(cd_MODIS, aes(x=EMBC,  y=MODIS_chl_mean_2002_2021)) + ylim(0,0.2)+
  geom_boxplot()+ ggtitle("EMB  Chl AVg2002-2021C")  + ylab("Avg Chl-a 2002-2021")


ggplot(cd_MODIS, aes(x=EMBC,  y=Chla_anomaly)) +# ylim(0,0.2)+
  geom_boxplot()+  xlab("Activity")+ ggtitle("EMB  Chl Anomaly")  + ylab("Chl-a ")

ggplot(cd_MODIS, aes(x=EMBC,  y=(chl_mean2020),fill=EMBC)) + ylab("Avg Chl-a 2020")+
  geom_boxplot() +  xlab("Activity") + ggtitle("EMBC-MODIS mean 2020 ")

### Meier --------------
m <-ggplot(cd_MODIS, aes(x=as.numeric(hour), fill=Meier)) + xlab("hour")

m + geom_density(aes(y = ..count..)) +
  facet_wrap(cd_MODIS$Meier)+ggtitle("Meier classification")

#MODIS and activity

ggplot(cd_MODIS, aes(x=Meier,  y=Chla_anomaly,fill=Meier)) + 
  geom_boxplot() +
  ylim(0,0.2)+  xlab("Activity")+ggtitle("Meyer Chl Anomaly")
#no pattern

#Chl_average

ggplot(cd_MODIS, aes(x=Meier,  y=MODIS_chl_mean_2002_2021,fill=Meier)) + ylab("Avg Chl-a 2002-2021")+ylim(0.15,0.25)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2002-2021")


ggplot(cd_MODIS, aes(x=Meier,  y=chl_mean2020,fill=Meier)) + ylab("Avg Chl-a 2020")+ylim(0.1,0.2)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2020")


### Pezzo --------------
p <-ggplot(cd_MODIS, aes(x=as.numeric(hour), fill=Pezzo)) + xlab("hour")

p + geom_density(aes(y = ..count..)) +
  facet_wrap(cd_MODIS$Pezzo)+ggtitle("Pezzo classification")

#MODIS and activity

#no pattern
rm (a,m,b,p)


#MODIS and activity

ggplot(cd_MODIS, aes(x=Meier,  y=Chla_anomaly,fill=Meier)) + 
  geom_boxplot() +
  ylim(0,0.2)+  xlab("Activity")+ggtitle("Pezzo Chl Anomaly")
#no pattern

#Chl_average

ggplot(cd_MODIS, aes(x=Pezzo,  y=MODIS_chl_mean_2002_2021,fill=Pezzo)) + ylab("Avg Chl-a 2002-2021")+ylim(0.15,0.25)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Pezzo-MODIS avg 2002-2021")


ggplot(cd_MODIS, aes(x=Pezzo,  y=chl_mean2020,fill=Pezzo)) + ylab("Avg Chl-a 2020")+ylim(0.15,0.25)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Meier-MODIS avg 2020")

## GLM ------

cd_MODIS$revisit2 <- 0
cd_MODIS[cd_MODIS$revisit=="Feeding", ]$revisit2 <- 1

glm1 <-glm(revisit2~Distance+Chla_anomaly+month, data=cd_MODIS, family = "binomial")

summary(glm1)
plot(glm1)

glm2 <-glm(revisit2~Distance+Chla_anomaly, data=cd_MODIS, family = "binomial")

summary(glm2)

glm3 <-glm(revisit2~Distance+chl_mean2020, data=cd_MODIS, family = "binomial")

summary(glm3)


## GLM ------

cd_MODIS$revisit2 <- 0
cd_MODIS[cd_MODIS$revisit=="Feeding", ]$revisit2 <- 1

glm1 <-glm(revisit2~distance+Chla_anomaly+month, data=cd_MODIS, family = "binomial")

summary(glm1)
plot(glm1)

glm2 <-glm(revisit2~distance+Chla_anomaly, data=cd_MODIS, family = "binomial")

summary(glm2)



# Sentinel2 -----------------------------

#load data with classification and sample
#Scopoli shearwater Berta maggiore
#C. diomedea  #############################
cd_S2 <- read.csv("/home/clara/lavori/biome/dati/cd_s2_dist.csv", stringsAsFactors=FALSE)

summary(cd_S2)
#datasetup
cd_S2$date <-as.POSIXct(cd_S2$timestamp)
cd_S2$hour <- hour(cd_S2$date)
cd_S2$hour <-as.factor(cd_S2$hour)
summary(cd_S2$hour)

cd_S2$month <- month(cd_S2$date)
cd_S2$month <-as.factor(cd_S2$month)
summary(cd_S2$month)

cd_S2$Distance <-cd_S2$distance*78
cd_S2$revisit <- as.factor(cd_S2$revisit )
#remove points on land

#FIXME cd_S2 <- cd_S2[cd_S2$distance>0,]


#Create a column with chla  for the right time

cd_S2$Chla <- 9000

summary(cd_S2$conc_chl__2020.07.29)
summary(cd_S2$conc_chl__2020.07.31) #piu alto 
summary(cd_S2$conc_chl__2020.08.10)
summary(cd_S2$conc_chl__2020.08.12)#piu alto 
summary(cd_S2$conc_chl__2020.09.04)#piu alto 
summary(cd_S2$conc_chl__2020.09.17)
summary(cd_S2$conc_chl__2020.10.08)
summary(cd_S2$conc_chl__2020.10.28)#piu alto 




cd_S2[cd_S2$month==7,]$Chla <- cd_S2[cd_S2$month==7,]$conc_chl__2020.07.31

cd_S2[cd_S2$date>'2020-08-01' & cd_S2$date<'2020-08-15',]$Chla <- 
  cd_S2[cd_S2$date>'2020-08-01' & cd_S2$date <'2020-08-15',]$conc_chl__2020.08.12

cd_S2[cd_S2$date>'2020-08-15' & cd_S2$date<'2020-08-31',]$Chla <- 
  cd_S2[cd_S2$date>'2020-08-15' & cd_S2$date <'2020-08-31',]$conc_chl__2020.08.21      


cd_S2[cd_S2$date>'2020-09-01' & cd_S2$date<'2020-09-15',]$Chla <- 
  cd_S2[cd_S2$date>'2020-09-01' & cd_S2$date <'2020-09-15',]$conc_chl__2020.09.04      

cd_S2[cd_S2$date>'2020-09-16' & cd_S2$date<'2020-09-30',]$Chla <- 
  cd_S2[cd_S2$date>'2020-09-16' & cd_S2$date <'2020-09-30',]$conc_chl__2020.09.17      

cd_S2[cd_S2$date>'2020-10-01' & cd_S2$date<'2020-10-15',]$Chla <- 
  cd_S2[cd_S2$date>'2020-10-01' & cd_S2$date <'2020-10-15',]$conc_chl__2020.10.08  

cd_S2[cd_S2$date>'2020-10-16' & cd_S2$date<'2020-10-31',]$Chla <- 
  cd_S2[cd_S2$date>'2020-10-16' & cd_S2$date <'2020-10-31',]$conc_chl__2020.10.28  

summary(cd_S2$Chla  )

#Remove NA
cd_S2<- cd_S2[cd_S2$Chla<9000,]
cd_S2 <-cd_S2[!is.na(cd_S2$Chla),] 
summary(cd_S2)

#FIXME join distance and other Class!
test <-merge(x = cd_S2, y = cd_MODIS[ , c("fid", "distance", "EMBC","revisit")], by = "fid", all.x=TRUE)
#errors in merge 
table(test$revisit.x,test$revisit.y)

## graphic EDA S2 ---------
#var distribution
plot(density(cd_S2$distance))
plot(table(cd_S2$hour))
plot(table(cd_S2$month))
plot(table(cd_S2$revisit))
plot(density(cd_S2$Chla))

### Recourse activity patterns -----------

a <-ggplot(cd_S2, aes(x=as.numeric(hour), fill= revisit)) 

a+  geom_bar(stat = "count",position = "dodge")

a + geom_density(aes(y = ..count..)) + xlab("hour")+xlim(0,23)+
  facet_wrap(cd_S2$revisit)+ggtitle("Recourse Analisys")

# done with all data , does not change 
ggplot(cd_S2, aes(x=month, fill= revisit)) +
  geom_bar(stat = "count",position = "dodge")+ggtitle("Recourse Analisys")
#S2 and activity
#FIXME class
ggplot(cd_S2, aes(x=revisit,  y=log(Chla) , fill=revisit)) + ylim(-0.50,0.5)+
  geom_boxplot() +  xlab("Activity") + ggtitle("Recourse S2")
# pattern!

### EMBC -----------

#FIXME join data
#no pattern
ggplot(cd_S2, aes(x=meier,  y=Chla)) +# ylim(0,0.2)+
  geom_boxplot()+  xlab("Activity")+ggtitle("Meyer S2")
#no pattern

### Meyer --------------

## GLM ------

cd_S2$revisit2 <- 0
cd_S2[cd_S2$revisit=="Feeding", ]$revisit2 <- 1

glm1 <-glm(revisit2~Distance+Chla, data=cd_S2, family = "binomial")

summary(glm1)
plot(glm1)

glm2 <-glm(revisit2~distance+Chla+month, data=cd_S2, family = "binomial")

summary(glm2)



