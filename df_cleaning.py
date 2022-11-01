import pandas as pd
import os


filepath = os.path.abspath('') # it returns the wd, this line is imp since we work locally from different devices

# "Data/df_Calonectris diomedea.csv"
# "Data/df_Puffinus yelkouan.csv"

berta = "Data/df_Calonectris diomedea.csv"


# "Data/Puffinus yelkouan Montecristo/points.csv"
# "Data/Scopoli's Shearwater, Zenatello, Tuscan Archipelago/points.csv"
filename = "Data/Scopoli's Shearwater, Zenatello, Tuscan Archipelago.csv"
rslt_df = pd.read_csv(filename)

rslt_df = pd.DataFrame({ "device_id" : rslt_df["tag-local-identifier"], "timestamp": rslt_df["timestamp"], "Latitude": rslt_df["location-lat"],
    "Longitude": rslt_df["location-long"], "timestamp": rslt_df["timestamp"], "Speed_m_s": rslt_df["ground-speed"]})


rslt_df.to_csv(berta)
