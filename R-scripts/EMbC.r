library(EMbC)
library(dplyr)


wd <- "C:\\Users\\micci\\Desktop\\Monitoring-seabirds-through-satellite-images\\Data"
setwd(wd)

df <- read.csv("df_Calonectris diomedea.csv")
head(df)

df2 <- df %>% select("timestamp", "Longitude", "Latitude", "device_id")

## Remove long e lat = 0 (i.e. missing data)
# df2 <- df2[df2$Longitude != 0, ]

# creo una nuova colonna in cui assegno un numero univoco per individuo. 
# Mi servirà poi per il loop

unico <- df2 %>% group_by(device_id) %>% group_indices(device_id) 
df2$ID_num <- unico

df2$timestamp <- as.POSIXct(strptime(df2$timestamp, format="%Y-%m-%d %H:%M:%S"),format="%Y-%m-%d %H:%M:%S",tz="UTC")
### EMbC Analysis
# Analysis based on two variables: speed velocity and turning angle

# - Low/Low = Rest
# - Low/High = Forage
# - High/Low = Travel
# - High/High = Active search for food


berte.cat <- data.frame() # questo mi serve per poi esportarlo
embc_l <- list() # questo mi serve per mantenere l'oggetto binClust e poterne osservare i plot diagnostici


for (i in 1:nlevels(as.factor(df2$ID_num))) {
 
 ## Creo df con 1 solo animale
 ind.df <- df2[df2$ID_num == i, ] 
 
  # stbc() is a specific constructor for the behavioural annotation of movement trajectories;
  # return an object of class binClstPath with the bivariate (velocity/turn) clustering of 
  # the trajectory;
  bc <- stbc(ind.df, info = -1)
  # The smth() function applies a post-smoothing procedure (Garriga et al. 2016) to the output labelling and 
  # returns a smoothed copy of the input instance
  postbc <- smth(bc, dlta = 1)
  embc_l[[i]] <- postbc
  # postbc@A, a numeric vector with the output labelling of each location, (the number of the cluster with 
  # the highest likelihood weight, coded as 1:LL, 2:LH, 3:HL, and 4:HH)
  dati <- data.frame(ind.df, Classification = postbc@A, mean_speed = postbc@X[,1])

  berte.cat <- rbind(berte.cat, dati)
    
}

df$EMbC_classif <- berte.cat[, "Classification"]

write.csv(df, "C:\\Users\\micci\\Desktop\\Monitoring-seabirds-through-satellite-images\\Data\\Classified df\\Calonectris diomedea_EMbC.csv")

