
import pandas as pd
import datetime

'''
Function to classify birds activity 
where:
Speed  < 2.5 m/s the bird is resting
Speed > 2.5 the bird is travelling or foraging
These are discriminated by the tortuosity index (TI) where:
TI < 0.98 the bird is foraging
TI > 0.98 the bird is travelling

'''

def classification(row):
    if row["Speed_m_s"] < 2.5:
        return "R"
    else:
        if row["tortuosity index"] < 0.98:
            return "F"
        else:
            return "T"

'''
Another function to classify birds acctivity (Meier 2015)
Where:
All the fix with speed velocity > 7 m/s are classified as commuting flights
Fix taken by night are all associated to rest
All the others are foraging 

'''

def classification2(row):
    start = datetime.time(21, 0, 0)
    end = datetime.time(4, 0, 0)

    if row["Speed_m_s"] > 7:
            return "T"
    else:
        if time_in_range(start, end, row["time"]):
                return "R"
        else:
            return "F"

'''
Function to filter the df based on the timestamp

'''
def time_in_range(start, end, x):
    """Return true if x is in the range [start, end]"""
    if start <= end:
        return start <= x <= end
    else:
        return start <= x or x <= end

