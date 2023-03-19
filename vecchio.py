import pandas as pd
import os
import numpy as np
# import geopy.distance
# import contextily as ctx
from Functions import  classification, classification2
from haversine import haversine

filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# VECCHIA CLASSIFICAZIONE BASTATA SOLO SU VALORE SOGLIA "2.5 E TORTUOSITY INDEX"
# NON CORRETTO

# # Let's calculate the arc for each point which is the distance among three consecutive points 
# df["arc"] = df.groupby("device_id")["geo_dist"].apply(lambda x: x + x.shift(-1))
# # Let's calculate the chord which is the distance between a point and the second consecutive 
# df["chord"] = df.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['Latitude3'], x['Longitude3'])) if x['Latitude3'] > 0 or x['Longitude3'] > 0 else 0, axis =1)

# # I have to transform 0 value in NaN oterwise I cannot divide because I have 0 values in df["arco"]
# df["arc"] = df["arc"].replace({ 0:np.nan})
# # Let's calculate the tortuosity index
# df["tortuosity index"] = df["chord"]/df["arc"] 


# # Let's do the median in each row of the df["Speed_m_s"] in m/s with the following 4 values
# # probably I have a multiindex problem so i have to apply reset_index()
# med = df.groupby("device_id")["Speed_m_s"].rolling(5).median().shift(-4)
# df["median"] = med.reset_index(level=0, drop=True)
# # replace Nan value with the corresponding value of df["Speed_m_s"]
# df["median"].fillna(df["Speed_m_s"], inplace=True)



'''
Function to classify birds activity 
where:
Speed  < 2.5 m/s the bird is resting
Speed > 2.5 the bird is travelling or foraging
These are discriminated by the tortuosity index (TI) where:
TI < 0.98 the bird is foraging
TI > 0.98 the bird is travelling
'''


#def classification(row):
#    if row["Speed_m_s"] < 2.5:
#        return "R"
#    else:
#        if row["tortuosity index"] < 0.98:
#            return "F"
#        else:
#            return "T"

