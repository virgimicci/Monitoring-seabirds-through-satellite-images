import pandas as pd
import numpy as np
import os
# from functions import classification
import geopy.distance
from functions import distance 
from functions import tortuosity

filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices
df = pd.read_csv('Data/FileberteAnalisiIndividuale.csv')

# Creation of a new col where we classify 
# the bird action of Travelling(T), Foraging (F) and Resting (R)
# in relation to their speed velocity
# Where: 
# > 10 Km/h T
# < 5 Km/h R
# 5 Km/h < F < 10 Km/h

# df['birds_activity'] = df.apply(classification, axis=1)

# sum(df['birds_activity'] == "F") # 1617

# Creation of a df with just foraging data

#df_F = df[df["birds_activity"] == "F"]

df["time"] =pd.to_timedelta(df['UTC_time'])
df["interval"]=df.groupby("device_id").time.diff().dt.seconds.div(60)


# Creating new col with shifted values of lat and long to calculate distances
df[['Latitude2', 'Longitude2']] = df[['Latitude', 'Longitude']].shift(-1)
df[['Latitude3', 'Longitude3']] = df[['Latitude', 'Longitude']].shift(-2)

# I would use geopy function to calculate the distance because is more accurate
# but it gives me problem while I try to sum the values for the df["arco"]
df['geo_dist'] = df.apply(lambda x: distance((x['Latitude'], x['Longitude']) , (x['Latitude2'], x['Longitude2'])) if x['Latitude2'] > 0 or x['Longitude2'] > 0 else 0, axis=1)
# df['distance_km'] = df.apply(lambda row: distance(row['point'], row['point_next']).km if row['point_next'] is not None else float('nan'), axis=1)

df["arco"] = df.groupby("device_id")["geo_dist"].apply(lambda x: x.shift(-1) + x.shift(-2))
df["corda"] = df.apply(lambda x: geopy.distance.geodesic((x['Latitude'], x['Longitude']),(x['Latitude3'], x['Longitude3'])) if x['Latitude3'] > 0 or x['Longitude3'] > 0 else 0, axis =1)
