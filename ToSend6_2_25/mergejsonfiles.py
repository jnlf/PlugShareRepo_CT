import pandas as pd
import os

def merge_json_to_csv(directory_path, output_file_path):
    json_files = [f for f in os.listdir(directory_path) if f.endswith(".json")]
    dfs = []
    for file in json_files:
        file_path = os.path.join(directory_path, file)
        df = pd.read_json(file_path,orient='index')
        dfs.append(df)
    merged_df = pd.concat(dfs)
    merged_df.to_csv(output_file_path, index=False)

if __name__ == "__main__":
    directory_path = "/home/void/Desktop/Research/PlugShareCrawleeProject/storage/datasets/default"
    output_file_path = "output.csv"
    merge_json_to_csv(directory_path, output_file_path)
