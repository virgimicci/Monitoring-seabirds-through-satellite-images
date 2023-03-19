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
require(rgdal)

setwd("/data/gitlab/Monitoring-seabirds-through-satellite-images/" )


#Calonectris diomedea                    #############################
# Berta maggiore - Scopoli's shearwater 


#load data with all classifications
berta_EMbC <- read.csv("/data/gitlab/Monitoring-seabirds-through-satellite-images/Data/Classified df/Calonectris diomedea_EMbC_activity12.csv")
summary(berta_EMbC)

berta_EMbC <- na.omit(berta_EMbC)
berta_EMbC$date <- as.POSIXct(berta_EMbC$timestamp)
berta_EMbC$device_id <- as.factor(berta_EMbC$device_id)
berta_EMbC$time <- format(as.POSIXct(berta_EMbC$timestamp, format = "%H:%M:%S"))

#Track2BA data preparation


dataGroup <- formatFields(
  dataGroup = berta_EMbC[,c("device_id","date","time", "Longitude","Latitude" )], 
  fieldID   = "device_id", 
  fieldDate = "date", 
  fieldTime = "time",
  fieldLon  = "Longitude", 
  fieldLat  = "Latitude"
)

str(dataGroup)

#Subsetting for Colonies ----------------
#We have more than one colony!

levels(berta_EMbC$device_id)

#Cerboli
cerboli <- c("201573", "201574", "201575", "201576", "201577", "201578" ,"201579" ,"201580")

#Giannutri
giannutri <-c("201564", "201565", "201566", "201567", "201568", "201569", "201570", "201572" )

#Scola + pianosa
scola <- c("202311", "202312", "202307" , "202315" ,"202316","201588", 
          "201589", "201590", "201591", "201592", "201593", "201594",  "201571",
          "202313","202308" ,"202309", "202314", "202317" )

#Argentarola
argentarola <-c("201581", "201582" ,"201583" ,"201584", "201585", "201586" ,"201587")

#Pianosa
#pianosa <-c( "202308" ,"202309", "202314", "202317")

## Cerboli ---------------

cerboli_data <- dataGroup[dataGroup$ID %in% cerboli,]

# identify the location(s) of the central place(s) (e.g. colony-center, or nest sites).

colony <-  data.frame(Longitude = 10.55 , Latitude  =  42.86)
  
#nice map
#my_sf <- st_as_sf(cerboli_data, coords = c('Longitude', 'Latitude'))
#my_sf <- st_set_crs(my_sf,4326)
#mapview(my_sf)

trips <- tripSplit(
  dataGroup  = cerboli_data,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 10,
  duration   = 3,      # hours
  rmNonTrip  = TRUE 
)

mapTrips(trips = trips, colony = colony)

#Then we can summarize the trip movements, using tripSummary. 
#keep all data becasuse nobodi returns


tracks <- projectTracks(dataGroup = trips[trips$ID %in% cerboli, ], projType = 'azim', custom=TRUE )
class(tracks)

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


tracks <- tracks[tracks$ColDist > 3, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 3, 
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

mapview(Site["N_IND"])
###export for view in QGIS ----

writeGDAL(Site["N_IND"], "cd_cerboli.tif")



## Giannutri ---------------

giannutri <-c("201564", "201565", "201566", "201567", "201568", "201569", "201570", "201572" )
giann_data <- dataGroup[dataGroup$ID %in% giannutri,]

# identify the location(s) of the central place(s) (e.g. colony-center, or nest sites).
# here we know that the first points in the data set are from the colony center

colony <-  data.frame(Longitude = 11.09 , Latitude  =  42.25)


trips <- tripSplit(
  dataGroup  = giann_data,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 10,
  duration   = 3,      # hours
  rmNonTrip  = TRUE 
)

mapTrips(trips = trips, colony = colony)

#Then we can summarize the trip movements, using tripSummary. 

tracks <- projectTracks(dataGroup = trips, projType = 'azim', custom=TRUE )
tracks <- tracks[tracks$ColDist > 3, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 3, 
  levelUD = 50, 
  polyOut = TRUE
)

mapKDE(KDE = KDE$UDPolygons, colony = colony)

repr <- repAssess(
  tracks    = tracks, 
  KDE       = KDE$KDE.Surface,
  levelUD   = 50,
  iteration = 1, 
  bootTable = FALSE)

#Data  91& representative!

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

mapview(Site["N_IND"])
###export for view in QGIS ----

writeGDAL(Site["N_IND"], "cd_giannutri.tif")

## Pianosa ---------------

scola <- c("202311", "202312", "202307" , "202315" ,"202316","201588", 
           "201589", "201590", "201591", "201592", "201593", "201594",  "201571",
           "202313","202308" ,"202309", "202314", "202317" )

pianosa_data <- dataGroup[dataGroup$ID %in% scola,]

# identify the location(s) of the central place(s) (e.g. colony-center, or nest sites).
colony <-  data.frame(Longitude = 10.10 , Latitude  =  42.58)


trips <- tripSplit(
  dataGroup  = pianosa_data,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 10,
  duration   = 3,      # hours
  rmNonTrip  = TRUE 
)

mapTrips(trips = trips, colony = colony)

#Then we can summarize the trip movements, using tripSummary. 

tracks <- projectTracks(dataGroup = trips, projType = 'azim', custom=TRUE )
tracks <- tracks[tracks$ColDist > 3, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 3, 
  levelUD = 50, 
  polyOut = TRUE
)

mapKDE(KDE = KDE$UDPolygons, colony = colony)

repr <- repAssess(
  tracks    = tracks, 
  KDE       = KDE$KDE.Surface,
  levelUD   = 50,
  iteration = 1, 
  bootTable = FALSE)

#Data not representative!

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

mapview(Site["N_IND"])
###export for view in QGIS ----

writeGDAL(Site["N_IND"], "cd_pianosa.tif")




##Argentarola ---------------

argentarola <-c("201581", "201582" ,"201583" ,"201584", "201585", "201586" ,"201587")
arg_data <- dataGroup[dataGroup$ID %in% argentarola,]

# identify the location(s) of the central place(s) (e.g. colony-center, or nest sites).
colony <-  data.frame(Longitude = 11.08 , Latitude  =  42.41)


trips <- tripSplit(
  dataGroup  = arg_data,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 10,
  duration   = 3,      # hours
  rmNonTrip  = TRUE 
)

mapTrips(trips = trips, colony = colony)

tracks <- projectTracks(dataGroup = trips, projType = 'azim', custom=TRUE )
tracks <- tracks[tracks$ColDist > 3, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 3, 
  levelUD = 50, 
  polyOut = TRUE
)

mapKDE(KDE = KDE$UDPolygons, colony = colony)

repr <- repAssess(
  tracks    = tracks, 
  KDE       = KDE$KDE.Surface,
  levelUD   = 50,
  iteration = 1, 
  bootTable = FALSE)

#Data 92% representative!

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

mapview(Site["N_IND"])
###export for view in QGIS ----

writeGDAL(Site["N_IND"], "cd_arg.tif")

## sum rasters in a single one

files <- list.files(pattern="*.tif$", full.names=TRUE)

files
files <- files[-5]


rs <- stack(files)
#FIXME
#Error in compareRaster(rasters) : different extent
#Then, to create a sum of all your rasters use calc function (from raster package):

library(raster)
r1 = raster::brick( "./cd_arg.tif")
r2 = raster::brick("./cd_cerboli.tif"  )
r3 = raster::brick(  "./cd_giannutri.tif")
r4 = raster::brick("./cd_pianosa.tif"  )
extent(r1) <- extent(r2)
extent(r3) <- extent(r2)
extent(r2) <- extent(r2)

rs <- stack(r1,r3,r4)

  rs1 <- calc(rs, sum)
# Test multuiple nesting sites together -----------
  
  c <-  data.frame(ID= "Cerboli", Longitude = 10.55 , Latitude  =  42.86)
  g <-  data.frame(ID= "Giannutri",Longitude = 11.09 , Latitude  =  42.25)
  p <-  data.frame(ID= "Pianosa",Longitude = 10.10 , Latitude  =  42.58)
  a <-  data.frame(ID= "Argenterola",Longitude = 11.08 , Latitude  =  42.41)
  
colony <- rbind.data.frame(a,c,g,p)  

#must create a df with mathcing ID with Tracks

c <-  data.frame( ID= cerboli, Longitude =rep( 10.55,length(cerboli)), Latitude = rep( 42.86,length(cerboli),))
g <-  data.frame( ID= giannutri, Longitude =rep( 11.09,length(giannutri)), Latitude = rep( 42.25,length(giannutri),))
p <-  data.frame( ID= scola, Longitude =rep( 10.10,length(scola)), Latitude = rep( 42.58,length(scola),))
a <-  data.frame( ID= argentarola, Longitude =rep( 11.08,length(argentarola)), Latitude = rep( 42.41,length(argentarola),))

colony <- rbind.data.frame(a,c,g,p)  

trips <- tripSplit(
  dataGroup  = dataGroup,
  colony     = colony,
  innerBuff  = 3,      # kilometers
  returnBuff = 10,
  duration   = 3,      # hours
  rmNonTrip  = TRUE,
  nests=TRUE #for multuple locations
)

mapTrips(trips = trips, colony = colony)

tracks <- projectTracks(dataGroup = trips, projType = 'azim', custom=TRUE )
tracks <- tracks[tracks$ColDist > 3, ] # remove trip start and end points near colony

KDE <- estSpaceUse(
  tracks = tracks, 
  scale = 3, 
  levelUD = 50, 
  polyOut = TRUE
)

mapKDE(KDE = KDE$UDPolygons, colony = colony)

repr <- repAssess(
  tracks    = tracks, 
  KDE       = KDE$KDE.Surface,
  levelUD   = 50,
  iteration = 1, 
  bootTable = FALSE)

#Data 87.4% representative!

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

mapview(Site["N_IND"])
###export for view in QGIS ----

writeGDAL(Site["N_IND"], "cd_all.tif")
