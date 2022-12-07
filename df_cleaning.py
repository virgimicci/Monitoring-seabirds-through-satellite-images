import pandas as pd
import os
import zipfile


filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# berta will be the variable used to save the new csv
# "Data/df_Calonectris diomedea.csv"
# "Data/df_Puffinus yelkouan.csv"
berta = "Data/df_Puffinus yelkouan.csv"

# Let's read csv file 
# "Data/Scopoli's Shearwater, Zenatello, Tuscan Archipelago.zip"
zf = zipfile.ZipFile("Data/Scopoli's Shearwater, Zenatello, Tuscan Archipelago.zip") 

# We will assign to filename the the csv we want to open
# "Data/Puffinus yelkouan Montecristo .csv" or zf.open("Scopoli's Shearwater, Zenatello, Tuscan Archipelago.csv") since is a .zip file

filename = zf.open("Scopoli's Shearwater, Zenatello, Tuscan Archipelago.csv")
rslt_df = pd.read_csv(filename)

# Df exploration
# Check for NaN under an entire DataFrame
rslt_df.isnull().values.any() # False

# Check for 0 under Long/lat col
0 in rslt_df["location-long"].values # False
0 in rslt_df["location-lat"].values # False

# Check for duplicates 
rslt_df.duplicated().sum()

rslt_df = pd.DataFrame({ "device_id" : rslt_df["tag-local-identifier"], "timestamp": rslt_df["timestamp"], "Latitude": rslt_df["location-lat"],
    "Longitude": rslt_df["location-long"], "timestamp": rslt_df["timestamp"], "Speed_m_s": rslt_df["ground-speed"]})


rslt_df.to_csv(berta)
