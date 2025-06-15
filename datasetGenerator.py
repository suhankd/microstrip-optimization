import pandas as pd
import numpy as np

import random

num_datapoints = 100

data = []

for i in range(num_datapoints):

    w1 = np.random.uniform(high = 4e-3, low = 1.5e-3)
    w2 = np.random.uniform(high = 4e-3, low = 1.5e-3)

    l1 = np.random.uniform(high = 25e-3, low = 19e-3)
    l2 = np.random.uniform(high = 50e-3, low = 35e-3)

    r = np.random.uniform(high = 8e-3, low = 4e-3)
    
    fl = np.random.uniform(high = 22.5e-3, low = 15e-3)
    fw = np.random.uniform(high = 4e-3, low = 2e-3)

    datapoint = {
        'l1': l1,
        'l2': l2,
        'w1': w1,
        'w2': w2,
        'r': r,
        'fl': fl,
        'fw': fw}

    data.append(datapoint)


data = pd.DataFrame(data)
data.to_csv("generatedValues.csv", index = False)
