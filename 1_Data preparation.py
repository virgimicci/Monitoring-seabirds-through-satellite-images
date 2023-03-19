import pandas as pd
import os
import zipfile


filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# Let's read csv file 
# "Data/Original Data_MoveBank/Scopoli's Shearwater, Zenatello, Tuscan Archipelago.zip"
zf = zipfile.ZipFile("Data/Original Data_MoveBank/Scopoli's Shearwater, Zenatello, Tuscan Archipelago.zip") 

# We will assign to filename the the csv we want to open
# "Data/Original Data_MoveBank/Puffinus yelkouan Montecristo .csv" 
# or "Data/Original Data_MoveBank/Foraging movements of yelkouan shearwater (data from Pezzo et al. 2021).csv" 
# or zf.open("Scopoli's Shearwater, Zenatello, Tuscan Archipelago.csv") since is a .zip file

filename = zf.open("Scopoli's Shearwater, Zenatello, Tuscan Archipelago.csv")
rslt_df = pd.read_csv(filename)

# Df exploration
# Check for NaN under an entire DataFrame
rslt_df.isnull().values.any()
rslt_df.isna().sum()

# if needed rslt_df = rslt_df.dropna() 

# Check for 0 under Long/lat col
0 in rslt_df["location-long"].values # False
0 in rslt_df["location-lat"].values # False

# Check for duplicates 
rslt_df.duplicated().sum()

df = pd.DataFrame({ "device_id" : rslt_df["tag-local-identifier"], "timestamp": rslt_df["timestamp"], "Latitude": rslt_df["location-lat"],
    "Longitude": rslt_df["location-long"], "Speed_m/s": rslt_df["ground-speed"], "col_id": rslt_df["individual-local-identifier"]})

