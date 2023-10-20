#!/usr/bin/env python

import numpy as np
import os
from pathlib import Path
import pandas as pd
import sys

def convert_numbers_in_string(string):
    numeric_part = ""
    
    if string.isnumeric():
        return string
    
    for char in string:
        if char.isnumeric():
            numeric_part += char
        else:
            if numeric_part:
                return int(numeric_part)
    
    return np.nan

path_to_c = Path(sys.argv[1])
name = str(sys.argv[2])

slurm_filenames = filter(lambda x: x.endswith(".out"), os.listdir(path_to_c))
slurm_paths = map((lambda x: path_to_c / x), slurm_filenames)

bwa_filenames = filter(lambda x: x.startswith("bwa-mem2-index"), os.listdir(path_to_c))
bwa_paths = map((lambda x: path_to_c / x), bwa_filenames)

pd_datasize = pd.read_csv(path_to_c/"datasizes.tsv", names=['size', 'bin_id'], skiprows=1, sep='\t', dtype=str)

##filling the dataframe
df = pd.read_csv(path_to_c/"nodelist.csv", names=['bin_id', 'Nodes'], header=None)
df["Data Size in mb"] = ""
df["Total-time"] = ""
df["CPU-time"] = ""
df["max-rss"] = ""
df["I/O In (read MB)"] = ""
df["I/O out (write MB)"] = ""
df["mem_mb"] = ""
df["disk_mb"] = ""

max_bin = convert_numbers_in_string(df['bin_id'].iloc[-1])
for slurm_out in slurm_paths:
    with open(slurm_out, "r") as f:
        bin_id = 0
        for line in f:
            tmp = ""
            line = line.strip()
            if ('wildcards:' in line):
                bin_id = convert_numbers_in_string(line)           
            elif ('esources:' in line):
                tmp = line.strip().split()
                for i in tmp:
                    if i.startswith("mem_mb"):
                        tmp[2] = i
                    elif i.startswith("disk_mb"):
                        tmp[4] = i          
            if tmp:
                df.at[bin_id,"mem_mb"] = convert_numbers_in_string(tmp[2])
                df.at[bin_id,"disk_mb"] = convert_numbers_in_string(tmp[4])

for bwa_out in bwa_paths:
    bwa_str = str(bwa_out)[-7:]
    bin_id = convert_numbers_in_string(bwa_str)
    with open(bwa_out, "r") as f:
        bwa_csv = pd.read_csv(bwa_out, sep='\t', header=0)
        df.at[bin_id,"Total-time"] = min(bwa_csv.iat[0,0],bwa_csv.iat[1,0])
        df.at[bin_id,"CPU-time"] = min(bwa_csv.iat[0,9],bwa_csv.iat[1,9])
        df.at[bin_id,"max-rss"] = max(bwa_csv.iat[0,2],bwa_csv.iat[1,2])
        df.at[bin_id,"I/O In (read MB)"] = max(bwa_csv.iat[0,6],bwa_csv.iat[1,6])
        df.at[bin_id,"I/O out (write MB)"] = max(bwa_csv.iat[0,7],bwa_csv.iat[1,7])

for i, row in pd_datasize.iterrows():
    bin_id = convert_numbers_in_string(row['bin_id'])
    datasize = row['size']
    df.at[bin_id, 'Data Size in mb'] = datasize



name = "result_" + name + "_bins_" + str(max_bin) + ".csv"
name = Path(name)
df.to_csv(name, index=False)