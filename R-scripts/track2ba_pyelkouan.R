################################################################
#   BIOME project
#   Berte e clorofilla
#
# 
# GPL (C) Clara Tattoni started 13/03/2023 
#
#
# apply  birdlife package to dataset
#https://github.com/BirdLifeInternational/track2kba
##########################################################

# load libs and set wd -----------
library(track2KBA) # load package
library (plyr) ## relevel and other nice stuff with tables
library (dplyr)
library(sp)
library(bayesmove) #prepare movement data in one command
library(ggplot2)
library(sf) #create objects to map
library(mapview) #for nice map viewing

setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )

#load data
#Yelkouan shearwater Berta minore
#P. yelkouan  #############################


#https://rdrr.io/cran/bayesmove/man/prep_data.html


yelkouan <-  read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/Classified df/Puffin_yelk_EMbC_activity12.csv")

yelkouan <- na.omit(yelkouan)
yelkouan$date <- as.POSIXct(yelkouan$timestamp)
yelkouan$device_id <- as.factor(yelkouan$device_id)
yelkouan$birds_activity1 <- as.factor(yelkouan$birds_activity1)
yelkouan$birds_activity2 <- as.factor(yelkouan$birds_activity2)
yelkouan$Tortuosity <- "T>0.98" 
yelkouan[yelkouan$tortuosity.index <0.98,  ]$Tortuosity <- "T<0.98" 
yelkouan$Tortuosity <- as.factor(yelkouan$Tortuosity)
yelkouan$time <- format(as.POSIXct(yelkouan$timestamp, format = "%H:%M:%S"))
#EMBC reclass
# 1- Low/Low = Rest
# 2- Low/High = Forage
# 3- High/Low = Travel
# 4- High/High = Active search for food

yelkouan$EMBC <- "R"
yelkouan[yelkouan$EMbC_classif== 1, ]$EMBC <- "R"
yelkouan[yelkouan$EMbC_classif== 2, ]$EMBC <- "F"
yelkouan[yelkouan$EMbC_classif== 3, ]$EMBC <- "T"
yelkouan[yelkouan$EMbC_classif== 4, ]$EMBC <- "AF"

yelkouan$EMBC <- as.factor(yelkouan$EMBC)



#Track2BA data preparation


dataGroup <- formatFields(
  dataGroup = yelkouan[,c("device_id","date","time", "Longitude","Latitude" )], 
  fieldID   = "device_id", 
  fieldDate = "date", 
  fieldTime = "time",
  fieldLon  = "Longitude", 
  fieldLat  = "Latitude"
)

str(dataGroup)

# identify the location(s) of the central place(s) (e.g. colony-center, or nest sites).
# here we know that the first points in the data set are from the colony center
colony <- dataGroup %>% 
  summarise(
    Longitude = first(Longitude), 
    Latitude  = first(Latitude)
  )

unique(dataGroup$ID)

#nice map
my_sf <- st_as_sf(yelkouan[yelkouan$device_id=="210453" ,], coords = c('Longitude', 'Latitude'))
my_sf <- st_set_crs(my_sf,4326)
mapview(my_sf)


tracks <- projectTracks( dataGroup = trips, projType = 'azim', custom=TRUE )
class(tracks)
#Track2BA analysis ---------------


# Our colony dataframe tells us where trips originate from. 
# Then we can set some parameters to decide what constitutes a trip. 
#  set innerBuff 
# (the minimum distance from the colony) to 3 km, and duration (minimum trip duration)
# to 24 hour. returnBuff can be set further out in order to catch incomplete trips,
# where the animal began returning, but perhaps due to device failure the 
# full trip wasn’t captured.
# O rmNonTrip to TRUE which will remove the periods when the animals were not on trips. The results of tripSplit can be plotted using mapTrips to see some examples of trips.

trips <- tripSplit(
  dataGroup  = dataGroup,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 50,
  duration   = 24,      # hours
  rmNonTrip  = FALSE #most do not return
)

mapTrips(trips = trips, colony = colony)

#Then we can summarize the trip movements, using tripSummary. 
#keep all data becasuse nobodi returns

trips <- subset(trips, trips$Returns == "Yes" )

sumTrips <- tripSummary(trips = trips, colony = colony)

sumTrips #returns error

#If we know our animal uses an area-restricted search (ARS) strategy to locate prey, 
#then we can set the scaleARS=TRUE. This uses First Passage Time analysis to identify the spatial scale at which area-restricted 
#search is occuring, which may then be used as the smoothing parameter value.

hVals <- findScale(
  tracks   = tracks,
  scaleARS = TRUE,
  sumTrips = sumTrips)

hVals


tracks <- tracks[tracks$ColDist > 1, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 5, 
  levelUD = 50, 
  polyOut = TRUE
)

mapKDE(KDE = KDE$UDPolygons, colony = colony)


# The relationship between sample size and the percent coverage of un-tested animals’ 
#space use areas (i.e. Inclusion) is visualized in the output plot seen below.

repr <- repAssess(
  tracks    = tracks, 
  KDE       = KDE$KDE.Surface,
  levelUD   = 50,
  iteration = 1, 
  bootTable = FALSE)

#Data may not be representative.

#delineate sites that meet some criteria of importance. 

Site <- findSite(
  KDE = KDE$KDE.Surface,
  represent = repr$out,
  levelUD = 50,
 # popSize =     # size of the colony, N individual seabirds breed one the island
  polyOut = FALSE
)

#class(Site)


mapSite(Site, colony = colony)


mapview(tracks) + mapview(Site)
mapview(Site["N_IND"])
#export for view in QGIS

###### Export for QGIS --------------------
require(rgdal)
writeGDAL(Site["N_IND"], "py_traxk2ba.tif")
