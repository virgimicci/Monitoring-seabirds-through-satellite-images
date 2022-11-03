import pandas as pd
import os
import numpy as np
# import geopy.distance
# import contextily as ctx
from functions import  classification, classification2
from haversine import haversine

filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# "Data/df_Puffinus yelkouan.csv"
# "Data/df_Calonectris diomedea.csv"
filename = "Data/df_Puffinus yelkouan.csv"
df = pd.read_csv(filename)

# get time col
df['time'] = pd.to_datetime(df["timestamp"]).dt.time
# get date col
df['date'] = pd.to_datetime(df["timestamp"]).dt.date

# get the interval
df['time_delta'] = pd.to_timedelta(df['time'].astype(str))
df["interval"]=df.groupby("device_id").time_delta.diff().dt.seconds.div(60)
df["interval"].mean() 

# Drop fix with an interval > 10 min 
df.drop(df[df['interval'] >= 12].index, inplace = True)

# Creating new col with shifted values of lat and long to calculate distances
df[['Latitude2', 'Longitude2']] = df[['Latitude', 'Longitude']].shift(-1)
df[['Latitude3', 'Longitude3']] = df[['Latitude', 'Longitude']].shift(-2)

# Calculate distances from a fix and following one with the haversine function
# I would use geopy function to calculate the distance because is more accurate
# but it gives me problem while I try to sum the values for the df["arco"], REMEMBER TO TRY TO FIX THE PROB 
df["geo_dist"] = df.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['Latitude2'], x['Longitude2'])) if x['Latitude2'] > 0 or x['Longitude2'] > 0 else 0, axis =1)

# Let's calculate the arc for each point which is the distance among three consecutive points 
df["arc"] = df.groupby("device_id")["geo_dist"].apply(lambda x: x + x.shift(-1))
# Let's calculate the chord which is the distance between a point and the second consecutive 
df["chord"] = df.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['Latitude3'], x['Longitude3'])) if x['Latitude3'] > 0 or x['Longitude3'] > 0 else 0, axis =1)

# I have to transform 0 value in NaN oterwise I cannot divide because I have 0 values in df["arco"]
df["arc"] = df["arc"].replace({ 0:np.nan})
# Let's calculate the tortuosity index
df["tortuosity index"] = df["chord"]/df["arc"] 


# Let's do the median in each row of the df["Speed_m_s"] in m/s with the following 4 values
# probably I have a multiindex problem so i have to apply reset_index()
med = df.groupby("device_id")["Speed_m_s"].rolling(5).median().shift(-4)
df["median"] = med.reset_index(level=0, drop=True)
# replace Nan value with the corresponding value of df["Speed_m_s"]
df["median"].fillna(df["Speed_m_s"], inplace=True)

### Let's make bird activity classification

# Creation of a new col where we classify 
# the bird action of Travelling(T), Foraging (F) and Resting (R)
# We use two methods

# Method 1
# in relation to their speed velocity and the tortuosity index (arc/chord)
# see classification function in functions.py

df['birds_activity1'] = df.apply(classification, axis=1)

# Method 2
# in relation to their speed velocity and the day time
# see classification2 function in functions.py

df['birds_activity2'] = df.apply(classification2, axis=1)

# sum(df['birds_activity'] == "F")

# I made a df with the col that i needed 
df_c = df[["device_id", "timestamp", "Longitude", "Latitude", 
    "Speed_m_s", "geo_dist", "arc", "chord",
    "tortuosity index", "birds_activity1", "birds_activity2"]].copy()

df_c.to_csv("Data/df_classif_Puffin_yelk.csv")



