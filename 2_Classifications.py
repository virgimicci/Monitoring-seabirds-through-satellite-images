import pandas as pd
import numpy as np
from Functions import classification2

'''
Let's make the bird activity classifications

Creation of a new col where we classify 
the bird action of Travelling(T), Foraging (F) and Resting (R)
We use two methods

'''

'''
Method 1
# Pezzo et al, 2015
'''

# Import colony df
colony = pd.read_csv("Data/Colony.csv")
colony = colony.rename(columns = {"Col_name": "colony"})

# I have to creata a col with the name of the colony
# Define a dictionary of patterns and corresponding words
pattern_dict = {'ARG': 'ARG', 'CERB': 'CERB', 'SCOLA': 'PIAN', 'BRIG': 'PIAN', 'GIAN': 'GIAN'}
df['colony'] = df['col_id'].apply(lambda x: next((v for k, v in pattern_dict.items() if x.startswith(k)), 'Unknown'))

# add colony coordinates to the df
df_merged = pd.merge(df, colony, on='colony')
df_merged = df_merged.rename(columns= {"xcoord": "col_long", "ycoord": "col_lat"})

# Now calculate the distance to the colony
df_merged["colony_dist_km"] = df_merged.apply(lambda x: haversine((x['Latitude'], x['Longitude']),(x['col_lat'], x['col_long'])), axis =1)

# Set up conditions for classification as 'T'
cond1 = (df_merged['Speed_m/s'] > 2.7) & (df_merged['geo_dist'] > 5) & (df_merged['interval']  < 14)
cond2 = (df_merged['Speed_m/s'] > 2.7) & (df_merged['geo_dist'] > 10) & (df_merged['interval'] > 15) & (df_merged['interval'] < 30)
cond3 = (df_merged['Speed_m/s'] > 2.7) & (df_merged['geo_dist'] > 30) & (df_merged['interval'] >= 30)
cond4 = (df_merged['Speed_m/s'] > 2.7) & (abs(df_merged["colony_dist_km"] - df_merged["colony_dist_km"].shift()) > 2.5) & (df_merged['interval'] < 14)
cond5 = (df_merged['Speed_m/s'] > 2.7) & (abs(df_merged["colony_dist_km"] - df_merged["colony_dist_km"].shift()) > 5) & (df_merged['interval'] > 15) & (df_merged['interval'] < 30)
cond6 = (df_merged['Speed_m/s'] > 2.7) & (abs(df_merged["colony_dist_km"] - df_merged["colony_dist_km"].shift()) > 15) & (df_merged['interval'] >= 30)

# Set up conditions for classification as 'R'
cond7 = (df_merged['Speed_m/s'] < 1.39) & (df_merged['geo_dist'] < 0.5) & (df_merged['interval']  < 30)
cond8 = (df_merged['Speed_m/s'] < 1.39) & (df_merged['geo_dist'] < 1.5) & (df_merged['interval']  >= 30)


df_merged['Pezzo_class'] = np.where(cond1 | cond2 | cond3 | cond4 | cond5 | cond6, 'T',
                                    np.where(cond7 | cond8, 'R' ,'F' ))


'''
# Method 2
# Meier et al, 2015
# in relation to their speed velocity and the day time
# see classification2 function in functions.py

'''

df_merged['Meier_class'] = df_merged.apply(classification2, axis=1)



# I made a df with the col that i needed 
df_c = df_merged[["device_id", "timestamp", "date", "time", "Longitude", "Latitude", 
    "Speed_m/s", "geo_dist", "col_id", "interval", "colony", "col_long",
     "col_lat", "colony_dist_km", "Pezzo_class", "Meier_class"]].copy()

# df_c.reset_index(drop=True, inplace=True)
df_c.to_csv("Data/Interm_Classif_df/df_classif_Calonec_diom.csv")
