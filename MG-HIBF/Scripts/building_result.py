#!/usr/bin/env python

import csv
#import numpy as np
import os
from pathlib import Path
#import pandas as pd
import sys

path_to_c = Path(sys.argv[1])
data_size = float(sys.argv[2])
name = str(sys.argv[3])
folder_list = os.listdir(path_to_c)
slurm_filenames = filter(lambda f: f.endswith(".out"), folder_list)

##filling the dataframe
df = pd.read_csv(path_to_c/nodes.csv, names=['bin_id', 'Nodes'], header=None)
df = df.set_index('bin_id')
df = df['Data Size in G'] = ""
df = df['Total-time'] = ""
df = df['CPU-time'] = ""
df = df['max-rss'] = ""
df = df['I/O In (read MB)'] = ""
df = df['I/O out (write MB)'] = ""
df = df['mem_mb'] = ""
df = df['disk_mb'] = ""


for slurm_out in slurm_filenames:
    with open(slurm_out, "r") as f:
        for line in f:
            line.strip()
            if (line.startswith('benchmark')):
                tmp1 = line.split()
                bwa_csv = pd.read_csv(path_to_c/tmp1[1], sep='\t', header=0)
                total_time = min(bwa_csv.iat[0,0],bwa_csv.iat[1,0])
                cpu_time = min(bwa_csv.iat[0,9],bwa_csv.iat[1,9])
                max_rss = min(bwa_csv.iat[0,2],bwa_csv.iat[1,2])
                io_in = min(bwa_csv.iat[0,6],bwa_csv.iat[1,6])
                io_out = min(bwa_csv.iat[0,7],bwa_csv.iat[1,7])
            elif (line.startswith('jobid:')):
                line.strip('jobid: ')
                bin_id = int(line)
                max_bin = max(bin_id+1, max_bin)
            elif (line.startswith('resources:')):
                tmp2 = line.split()
                mem_mb = tmp2[1].strip('mem_mb=')
                disk_mb = tmp2[3].strip('disk_mb=')
    df.at[bin_id,'Data Size in G'] = data_size/max_bin
    df.at[bin_id,'Total-time'] = total_time
    df.at[bin_id,'CPU-time'] = cpu_time
    df.at[bin_id,'max-rss'] = max_rss
    df.at[bin_id,'I/O In (read MB)'] = io_in
    df.at[bin_id,'I/O out (write MB)'] = io_out
    df.at[bin_id,'mem_mb'] = mem_mb
    df.at[bin_id,'disk_mb'] = disk_mb


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