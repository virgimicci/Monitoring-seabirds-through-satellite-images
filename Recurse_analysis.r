require(recurse)
require(scales)
require(dyplr)

wd <- "C:\\Users\\micci\\Desktop\\Monitoring-seabirds-through-satellite-images\\Data"
setwd(wd)

df <- read.csv("GeoPY_UTM.csv") %>% select( "location.long", "location.lat", "timestamp","tag.local.identifier")
head(df)

### Prova recurse package ###
#  Dataframe with four columns: x, y, timestamp (POSIXct or POSIXlt format) and id. 

df$timestamp <- as.POSIXct(df$timestamp)

plot(df$location.long, df$location.lat,  pch = 20, col = factor(df$tag.local.identifier), xlab = "Longitude", ylab = "Latitude", asp = 1)

visit_0.5 <- getRecursions(df2, 0.5)
visit_1 <- getRecursions(df2, 1) 
visit_2 <- getRecursions(df2, 2) 

plot(visit_0.5, df2, legendPos = c(15, -10))
plot(visit_1, df2, legendPos = c(15, -10))
plot(visit_2, df2, legendPos = c(15, -10))
