import csv
import numpy as np
import os
from pathlib import Path
import pandas as pd
import random as r
import subprocess
import sys


folder_list = os.listdir(Path(sys.argv[1]))
slurm_filenames = filter(lambda f: f.endswith(".out"), folder_list)

##filling the dataframe
df = pd.read_csv('../collect/nodes.csv', names=['bin_id', 'Nodes'], header=None)

df['Data Size'] = ""
df['Total-time'] = ""
df['CPU-time'] = ""
df['max-rss'] = ""
df['I/O In (read MB)'] = ""
df['I/O out (write MB)'] = ""
df['mem_mb'] = ""
df['disk_mb'] = ""

for slurm_out in slurm_filenames:
    with open(slurm_out, "r") as f:
        for line in f:
            line.strip()
            if (line.startswith('benchmark')):
                tmp1 = line.split()
                bwa_csv = pd.read_csv(tmp1[1])
            elif (line.startswith('jobid:')):
                line.strip('jobid: ')
                bin_id = line
            elif (line.startswith('resources:')):
                tmp2 = line.split()
                mem_mb = tmp2[1].strip('mem_mb=')
                disk_mb = tmp2[3].strip('disk_mb=')
                node = tmp2[4].strip('nodelist=')
            




            


            

            




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