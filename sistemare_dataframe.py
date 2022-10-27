# -*- coding: utf-8 -*-
"""
Created on Thu Oct 27 10:43:35 2022

@author: chiarasalv ♥
@birb: Berta Maggiore
"""

# Modules
import pandas as pd
import matplotlib.pyplot as plt
import geopandas as gpd
import rasterio 
from rasterio.plot import show
import matplotlib.colors as colors
#from tabulate import *

# Per formato data...
from datetime import datetime, timedelta
from matplotlib import dates as mpl_dates

# Original dataframe path...
csv_berta_magg_path = "C:/dati_berte/originals/berta_maggiore_2020.csv"

# Read dataframe...
bertamagg_ds = pd.read_csv(csv_berta_magg_path)
bertamagg_ds.head() # specifica che il dataset ha l'header già di default

# Read dataframe as GeoDataframe
# Geo-Dataframe
geo_df = gpd.GeoDataFrame(bertamagg_ds, geometry = gpd.points_from_xy(bertamagg_ds['Longitude'], bertamagg_ds['Latitude']))
# aggiungerà una colonna 'POINT' che conterrà le coordinate del punto di acquisizione GPS
# i valori verrano presi ovviamente dalle colonne 'Latitude' e 'Longitude'

# Sistemare il dataframe
# 1) splittare colonna 'timestamp' in due per ottenere
# due colonne 'Day' e 'Time'
# infine, spostare queste colonne vicino la colonna 'device_id'
# solo per una questione di ordine! ☻

# splitto la colonna in due...
geo_df[['Day', 'Time']] = geo_df.timestamp.str.split(" ", expand = True)

# creo un nuovo dataframe partendo da quello originale da cui 
# elimino la colonna 'timestamp'
new_df = geo_df.drop('timestamp', axis = 1)

# seleziono le colonne 'Day' e 'Time', che da spostare...
ii_col = new_df.pop('Day')
iii_col = new_df.pop('Time')

# ... e le vado ad inserire nella posizione - rispettivamente - 1 e 2 del dataframe
new_df.insert(1, 'Day', ii_col)
new_df.insert(2, 'Time', iii_col)

# variabile che contiene questo dataframe
df_bmagg = new_df

# Scrivo un nuovo .csv che contiene questo dataframe, specificando che non voglio l'indice!
output_path = "C:/dati_berte/originals/berta_maggiore_2020_totale_sistemato.csv"
df_bmagg.to_csv(output_path, index = False)

