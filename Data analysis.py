import pandas as pd
import geopandas as gpd
import numpy as np
import os
import geopy.distance
from shapely.geometry import Point
import matplotlib.pyplot as plt
import seaborn as sns
import contextily as ctx
from functions import  classification
from haversine import haversine

filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# "Data/gdf_Puffinus yelkouan.shp"
# "Data/gdf_Calonectris diomedea.shp"
filename = "Data/gdf_Puffinus yelkouan.shp"
gdf = gpd.read_file(filename)

# get time col
gdf['time'] = pd.to_datetime(gdf["timestamp"]).dt.time
# get date col
gdf['date'] = pd.to_datetime(gdf["timestamp"]).dt.date

# get the interval
gdf["time"] = pd.to_timedelta(gdf['time'].astype(str))
gdf["interval"]=gdf.groupby("device_id").time.diff().dt.seconds.div(60)
gdf["interval"].mean() 


# Drop fix with an interval > 10 min 
gdf.drop(gdf[gdf['interval'] >= 11].index, inplace = True)

# Creating new col with shifted values of lat and long to calculate distances
gdf[['Latitude2', 'Longitude2']] = gdf[['Latitude', 'Longitude']].shift(-1)
gdf[['Latitude3', 'Longitude3']] = gdf[['Latitude', 'Longitude']].shift(-2)

# Calculate distances from a fix and following one
# I would use geopy function to calculate the distance because is more accurate
# but it gives me problem while I try to sum the values for the df["arco"], REMEMBER TO TRY TO FIX THE PROB 
gdf["geo_dist"] = gdf.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['Latitude2'], x['Longitude2'])) if x['Latitude2'] > 0 or x['Longitude2'] > 0 else 0, axis =1)

# let's calculate the arc for each point which is the distance among three consecutive points 
gdf["arc"] = gdf.groupby("device_id")["geo_dist"].apply(lambda x: x + x.shift(-1))
# Let's calculate the chord which is the distance between a point and the second consecutive 
gdf["chord"] = gdf.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['Latitude3'], x['Longitude3'])) if x['Latitude3'] > 0 or x['Longitude3'] > 0 else 0, axis =1)

# I have to transform 0 value in NaN oterwise I cannot divide because I have 0 values in df["arco"]
gdf["arc"] = gdf["arc"].replace({ 0:np.nan})
gdf["tortuosity index"] = gdf["chord"]/gdf["arc"] 

#create a col with the speed in m/s
gdf["speed_m_s"] = gdf["Speed_km_h"].apply(lambda x: x/3.6)

# let's do the median in each row of the df["speed_m_s"] in m/s with the following 4 values
# probably I have a multiindex problem so i have to apply reset_index()
med = gdf.groupby("device_id")["speed_m_s"].rolling(5).median().shift(-4)
gdf["median"] = med.reset_index(level=0, drop=True)
# replace Nan value with the corresponding value of df["speed_m_s"]
gdf["median"].fillna(gdf["speed_m_s"], inplace=True)

### Let's make bird activity classification

# Creation of a new col where we classify 
# the bird action of Travelling(T), Foraging (F) and Resting (R)
# in relation to their speed velocity and the tortuosity index (arc/chord)
# see classification function in functions.py

gdf['birds_activity'] = gdf.apply(classification, axis=1)

sum(gdf['birds_activity'] == "F")

# I made a gpd with the col that i needed 
gdf_c = gdf[["device_id", "timestamp", "Longitude", "Latitude", "Speed_km_h", 
    "speed_m_s","geometry", "geo_dist", "arc", "chord",
    "tortuosity index", "birds_activity"]].copy()

gdf_c.to_file(filename= "Data/gdf_classif_puffin_yelk.shp")


# Creation of a df with just foraging data

df_F = gdf[gdf["birds_activity"] == "F"]


####  Kernel Density Estimation

# Create thresholds
#levels = [0.2,0.4,0.6,0.8,1]

# Create plot
#f, ax = plt.subplots(ncols=1, figsize=(10, 10))

# ax = df_F.plot(figsize=(10, 10), alpha=0.5, edgecolor='k')

# Kernel Density Estimation
#kde = sns.kdeplot(
#    ax = ax,
#    x = df_F['geometry'].x,
#    y= df_F['geometry'].y,
#    levels = levels,
#    shade = True,
#    cmap = 'Reds',
#    alpha = 0.9
#)
# Add a basemap
#ctx.add_basemap(ax = ax, crs = df_F.crs.to_string(), source = ctx.providers.CartoDB.Positron)
#ax.set_xticklabels(['{:,.0f}'.format(x) for x in ax.get_xticks()])
#ax.set_yticklabels(['{:,.0f}'.format(y) for y in ax.get_yticks()])
#plt.tight_layout()

#plt.show()

