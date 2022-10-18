
import math
import pandas as pd

# Function to calculate distance among two points
def distance(origin, destination):
    lat1, lon1 = origin
    lat2, lon2 = destination
    radius = 6371 # km

    dlat = math.radians(lat2-lat1)
    dlon = math.radians(lon2-lon1)
    a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = radius * c

    return d

# Function to classify birds activity 
# where:
# Speed  < 2.5 m/s the bird is resting
# Speed > 2.5 the bird is travelling or foraging
# these are discriminated by the tortuosity index (TI) where:
# TI < 0.98 the bird is foraging
# TI > 0.98 the bird is travelling

def classification(row):
    if row["speed_m_s"] < 2.5:
        return "R"
    else:
        if row["tortuosity index"] < 0.98:
            return "F"
        else:
            return "T"





    