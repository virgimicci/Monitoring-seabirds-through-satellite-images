
import pandas as pd
import datetime



'''
Function to classify birds acctivity (Meier 2015)
Where:
All the fix with speed velocity > 7 m/s are classified as commuting flights
Fix taken by night are all associated to rest
All the others are foraging 

'''

def classification2(row):
    start = datetime.time(21, 0, 0)
    end = datetime.time(7, 0, 0)

    if row["Speed_m/s"] > 7:
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

