import pandas as pd

dfs_merge = pd.DataFrame()

for i in range(15,21):

    df = pd.read_csv(f"Data\\generatedValues_{i}.csv")
    dfs_merge = dfs_merge._append(df)

dfs_merge.to_csv("merged_15to21.csv")