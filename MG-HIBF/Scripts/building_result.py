#!/usr/bin/env python

import csv
import numpy as np
import os
from pathlib import Path
import pandas as pd
import sys

path_to_c = Path(sys.argv[1])
data_size = float(sys.argv[2])
name = str(sys.argv[3])

slurm_filenames = filter(lambda x: x.endswith(".out"), os.listdir(path_to_c))
slurm_paths = map((lambda x: path_to_c / x), slurm_filenames)

##filling the dataframe
df = pd.read_csv(path_to_c/"nodelist.csv", names=['bin_id', 'Nodes'], header=None)
df = df.set_index('bin_id')
df["Data Size in G"] = ""
df["Total-time"] = ""
df["CPU-time"] = ""
df["max-rss"] = ""
df["I/O In (read MB)"] = ""
df["I/O out (write MB)"] = ""
df["mem_mb"] = ""
df["disk_mb"] = ""

max_bin = 1

for slurm_out in slurm_paths:
    with open(slurm_out, "r") as f:
        bin_id = 0
        for line in f:
            line = line.strip().strip('\n')
            print(line)
            if ('jobid:' in line):
                bin_id = int(line.strip('jobid: \t \n'))
                max_bin = max(bin_id+1, max_bin)
            elif ('.tsv' in line):
                tmp1 = line.split()
                bwa_csv = pd.read_csv(path_to_c/tmp1[1], sep='\t', header=0)
                df.at[bin_id,"Total-time"] = min(bwa_csv.iat[0,0],bwa_csv.iat[1,0])
                df.at[bin_id,"CPU-time"] = min(bwa_csv.iat[0,9],bwa_csv.iat[1,9])
                df.at[bin_id,"max-rss"] = min(bwa_csv.iat[0,2],bwa_csv.iat[1,2])
                df.at[bin_id,"I/O In (read MB)"] = min(bwa_csv.iat[0,6],bwa_csv.iat[1,6])
                df.at[bin_id,"I/O out (write MB)"] = min(bwa_csv.iat[0,7],bwa_csv.iat[1,7])
            elif ('resources:' in line):
                tmp2 = line.split()
                df.at[bin_id,"mem_mb"] = tmp2[1].strip('mem_mb=')
                df.at[bin_id,"disk_mb"] = tmp2[3].strip('disk_mb=') 

for i in range(0,max_bin):
    df.at[bin_id,"Data Size in G"] = data_size / max_bin

name = "result_" + name + "_" + str(data_size) + "G_bins_" + str(max_bin)
df.to_csv('../', index=False, column=False, archive_name=name)





##### Old_Code #####

# def NodeList():
#     cmd = ["bash", "-c", "sinfo --long --Node"]
#     result = subprocess.run(cmd, stdout=subprocess.PIPE)
#     return pd.read(result.decode('utf-8'))

# def NodeList_offline():
#     return pd.read_csv("../../NodeList.csv", header=0, index_col=False)

# def match_node (bin_nr):
#     list_of_Nodes = NodeList_offline()
#     return list_of_Nodes(NodeName[bin_nr])

# def NodeList():
#     cmd = ["bash", "-c", "sinfo -N"]        #| grep -P \"alloc|mix\" | grep -P big | awk '{print $1}'"
#     result = subprocess.run(cmd, stdout=subprocess.PIPE)
#     Nodepanda = pd.read_csv(result.decode('utf-8'))
#     return Nodepanda

# def change_config():
#     with open ('../simulation_config.yaml', 'w') as f:
#         config_file = yaml.load(f)
#         config_file['number_of_bins'] = n  