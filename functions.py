
import pandas as pd

# Function to classify birds activity 
# where:
# Speed  < 2.5 m/s the bird is resting
# Speed > 2.5 the bird is travelling or foraging
# these are discriminated by the tortuosity index (TI) where:
# TI < 0.98 the bird is foraging
# TI > 0.98 the bird is travelling

def classification(row):
    if row["Speed_m_s"] < 2.5:
        return "R"
    else:
        if row["tortuosity index"] < 0.98:
            return "F"
        else:
            return "T"

