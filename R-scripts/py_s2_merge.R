################################################################
#   BIOME project
#   Berte e clorofilla
#
# 
# GPL (C) Clara Tattoni started 20/03/2023 
#
#
# Prepare data S2 from separate to single file
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
#Prepare S@ data py
PY_EST <- read.csv("~/lavori/biome/dati/dachiara/datiberteminori2022/PY_EST_2022_OK.txt")
PY_NORD <- read.csv("~/lavori/biome/dati/dachiara/datiberteminori2022/PY_NORD_2022_OK.txt")
PY_SUD <- read.csv("~/lavori/biome/dati/dachiara/datiberteminori2022/PY_SUD_2022_OK.txt")
PY_2021 <- read.csv("~/lavori/biome/dati/dachiara/df_py_2021_finale!!!.csv")
#datasetup

PY_EST$date <-as.POSIXct(PY_EST$timestamp)
PY_EST$hour <- hour(PY_EST$date)
PY_EST$hour <-as.factor(PY_EST$hour)
summary(PY_EST$hour)

PY_EST$month <- month(PY_EST$date)
PY_EST$month <-as.factor(PY_EST$month)
summary(PY_EST$month)

PY_EST$revisit <- as.factor(PY_EST$revisit )

#Create a column with chla  for the right time

PY_EST$Chla <- 9000

summary(PY_EST$sudest__conc_chl__2022.05.17  )
summary(PY_EST$sudest__conc_chl__2022.05.24) #piu alto 
summary(PY_EST$sudest__conc_chl__2022.05.25)

PY_EST[PY_EST$date>'2022-05-16' & PY_EST$date<'2022-05-22',]$Chla <- 
  PY_EST[PY_EST$date>'2022-05-16' & PY_EST$date <'2022-05-22',]$sudest__conc_chl__2022.05.17
PY_EST[PY_EST$date>'2022-05-23' & PY_EST$date<'2022-05-25',]$Chla <- 
  PY_EST[PY_EST$date>'2022-05-23' & PY_EST$date <'2022-05-25',]$sudest__conc_chl__2022.05.24

summary(PY_EST$Chla  )

#Remove NA
PY_EST<- PY_EST[PY_EST$Chla<9000,]
PY_EST <-PY_EST[!is.na(PY_EST$Chla),] 
summary(PY_EST)

names(PY_EST)
keep <- c("fid" , "device_id",  "timestamp","revisit" ,                      
          "xcoord","ycoord",  "Chla" )
EST <-PY_EST[,  keep]


#SUD Create a column with chla  for the right time
PY_SUD$date <-as.POSIXct(PY_SUD$timestamp)
PY_SUD$Chla <- 9000

summary(PY_SUD)


PY_SUD[PY_SUD$date>'2022-05-01' & PY_SUD$date<'2022-05-12',]$Chla <- 
  PY_SUD[PY_SUD$date>'2022-05-01' & PY_SUD$date <'2022-05-12',]$sud__conc_chl__2022.05.12

PY_SUD[PY_SUD$date=='2022-04-30' ,]$Chla <- 
  PY_SUD[PY_SUD$date=='2022-04-30' ,]$sud__conc_chl__2022.04.26 

summary(PY_SUD$Chla  )

#Remove NA
PY_SUD<- PY_SUD[PY_SUD$Chla<9000,]
PY_SUD <-PY_SUD[!is.na(PY_SUD$Chla),] 
summary(PY_SUD)

names(PY_SUD)
keep <- c("fid" , "device_id",  "timestamp","revisit" ,                      
          "xcoord","ycoord",  "Chla" )
SUD <-PY_SUD[,  keep]




#NORD Create a column with chla  for the right time 2021 only
PY_NORD$date <-as.POSIXct(PY_NORD$timestamp)
PY_NORD$Chla <- 9000

summary(PY_NORD)

#2022 only
PY_NORD <- PY_NORD[PY_NORD$date>'2022-01-01',]

PY_NORD[PY_NORD$date>'2022-05-01' & PY_NORD$date<'2022-05-02',]$Chla <- 
  PY_NORD[PY_NORD$date>'2022-05-01' & PY_NORD$date <'2022-05-02',]$nord__conc_chl__2022.05.02

PY_NORD[PY_NORD$date>'2022-05-03' & PY_NORD$date<'2022-05-10',]$Chla <- 
  PY_NORD[PY_NORD$date>'2022-05-03' & PY_NORD$date <'2022-05-10',]$nord__conc_chl__2022.05.10

PY_NORD[PY_NORD$date>'2022-05-11',]$Chla <- 
  PY_NORD[PY_NORD$date>'2022-05-11' ,]$nord__conc_chl__2022.05.11


summary(PY_NORD$Chla  )

#Remove NA
PY_NORD<- PY_NORD[PY_NORD$Chla<9000,]
PY_NORD <-PY_NORD[!is.na(PY_NORD$Chla),] 
summary(PY_NORD)

names(PY_NORD)
keep <- c("fid" , "device_id",  "timestamp","revisit" ,                      
          "xcoord","ycoord",  "Chla" )
NORD <-PY_NORD[,  keep]


#2021 Create a column with chla  for the right time 2021 only
PY_2021$date <-as.POSIXct(PY_2021$timestamp)
PY_2021$Chla <- 9000

summary(PY_2021)

#2022 only

PY_2021[PY_2021$date<'2021-03-31',]$Chla <- 
  PY_2021[PY_2021$date<'2021-03-31' ,]$conc_chl__2021.03.31


PY_2021[PY_2021$date>'2021-04-01' & PY_2021$date<'2021-04-20',]$Chla <- 
  PY_2021[PY_2021$date>'2021-04-01' & PY_2021$date <'2021-04-20',]$conc_chl__2021.04.05

PY_2021[PY_2021$date>'2021-04-20' & PY_2021$date<'2021-04-30',]$Chla <- 
  PY_2021[PY_2021$date>'2021-04-20' & PY_2021$date <'2021-04-30',]$conc_chl__2021.04.23 

PY_2021[PY_2021$date>'2021-05-01' & PY_2021$date<'2021-05-15',]$Chla <- 
  PY_2021[PY_2021$date>'2021-05-01' & PY_2021$date <'2021-05-15',]$conc_chl__2021.05.08


PY_2021[PY_2021$date>'2021-05-15',]$Chla <- 
  PY_2021[PY_2021$date<'2021-05-15' ,]$conc_chl__2021.05.20


summary(PY_2021$Chla  )

#Remove NA
PY_2021<- PY_2021[PY_2021$Chla<9000,]
PY_2021 <-PY_2021[!is.na(PY_2021$Chla),] 
summary(PY_2021)

names(PY_2021)
keep <- c("fid" , "device_id",  "timestamp","revisit" ,                      
          "xcoord","ycoord",  "Chla" )
p2021 <-PY_2021[,  keep]

py_s2 <-rbind(NORD,SUD,EST,p2021)

write.csv(py_s2, file="/home/clara/lavori/biome/dati/dachiara/py_S2_meerged.csv")
#--