import pandas as pd
import numpy as np
import os
import geopy.distance
from functions import distance, classification

filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices
df = pd.read_csv('Data/FileberteAnalisiIndividuale.csv')

#df["time"] =pd.to_timedelta(df['UTC_time'])
#df["interval"]=df.groupby("device_id").time.diff().dt.seconds.div(60)

 
# Creating new col with shifted values of lat and long to calculate distances
df[['Latitude2', 'Longitude2']] = df[['Latitude', 'Longitude']].shift(-1)
df[['Latitude3', 'Longitude3']] = df[['Latitude', 'Longitude']].shift(-2)

# I would use geopy function to calculate the distance because is more accurate
# but it gives me problem while I try to sum the values for the df["arco"], REMEMBER TO TRY TO FIX THE PROB 
df['geo_dist'] = df.apply(lambda x: distance((x['Latitude'], x['Longitude']) , (x['Latitude2'], x['Longitude2'])) if x['Latitude2'] > 0 or x['Longitude2'] > 0 else 0, axis=1)

# let's calculate the arc for each point which is the distance among three consecutive points 
df["arc"] = df.groupby("device_id")["geo_dist"].apply(lambda x: x + x.shift(-1))
# Let's calculate the chord which is the distance between a point and the second consecutive 
df["chord"] = df.apply(lambda x: geopy.distance.geodesic((x['Latitude'], x['Longitude']),(x['Latitude3'], x['Longitude3'])) if x['Latitude3'] > 0 or x['Longitude3'] > 0 else 0, axis =1)

# I have to transform 0 value in NaN oterwise I cannot divide because I have 0 values in df["arco"]
df["arco"] = df["arco"].replace({ 0:np.nan})
df["tortuosity index"] = df["corda"]/df["arco"] 

#create a col with the speed in m/s
df["speed_m_s"] = df["speed_km_h"].apply(lambda x: x/3.6)

# let's do the median in each row of the df["speed_m_s"] in m/s with the following 4 values
# probably I have a multiindex problem so i have to apply reset_index()
med = df.groupby("device_id")["speed_m_s"].rolling(5).median().shift(-4)
df["median"] = med.reset_index(level=0, drop=True)
# replace Nan value with the corresponding value of df["speed_m_s"]
df["median"].fillna(df["speed_m_s"], inplace=True)

### Let's make bird activity classification

# Creation of a new col where we classify 
# the bird action of Travelling(T), Foraging (F) and Resting (R)
# in relation to their speed velocity and the tortuosity index (arc/chord)
# see classification function in functions.py

df['birds_activity'] = df.apply(classification, axis=1)

sum(df['birds_activity'] == "F") # 12450

# Creation of a df with just foraging data

df_F = df[df["birds_activity"] == "F"]


