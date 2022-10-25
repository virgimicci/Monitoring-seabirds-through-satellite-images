library(EMbC)
library(dplyr)


wd <- "C:\\Users\\micci\\Desktop\\Monitoring seabirds\\Monitoring-seabirds-through-satellite-images\\Data"
setwd(wd)

df <- read.csv("FileBerteAnalisiIndividuale.csv")
head(df)
df2 <- df %>% filter(device_id == 201564) %>% select("UTC_datetime", "Longitude", "Latitude")
head(df2)

shwbc <- stbc(df2)

df2$BA <-  shwbc@A
