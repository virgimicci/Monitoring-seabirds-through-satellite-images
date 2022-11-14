# add modules

def split_daytime(df):
    df[['Day', 'Time']] = df.timestamp.str.split(" ", expand = True)
    new_df = df.drop('timestamp', axis = 1)
    ii_col = new_df.pop('Day')
    iii_col = new_df.pop('Time')
    new_df.insert(1, 'Day', ii_col)
    new_df.insert(2, 'Time', iii_col)
    return new_df
