#Testfile for changing Parameters in the Workflow

import subprocess
import pandas as pd
import numpy as np
import random as r

#Loading available Nodes
def NodeList():
    cmd = ["bash", "-c", "sinfo --long --Node"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    return pd.read(result.decode('utf-8'))

def NodeList_offline():
    return pd.read_csv("../../NodeList.csv", header=0, index_col=False)

def match_node (bin_nr):
    list_of_Nodes = NodeList_offline()
    return list_of_Nodes(NodeName[bin_nr])


# def NodeList():
#     cmd = ["bash", "-c", "sinfo -N"]        #| grep -P \"alloc|mix\" | grep -P big | awk '{print $1}'"
#     result = subprocess.run(cmd, stdout=subprocess.PIPE)
#     Nodepanda = pd.read_csv(result.decode('utf-8'))
#     return Nodepanda

def change_config():
    with open ('../simulation_config.yaml', 'w') as f:
        config_file = yaml.load(f)
        config_file['number_of_bins'] = n  

#!/usr/bin/bash
"""
#replace YOUR_PATH_HERE, with the directory you want your csv file in
path_for_csv='YOUR_PATH_HERE'
path_to_files='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
number_of_files=$(find $path_to_files -type f | wc -l)

#gets you a csv file with index, Size and Name, the seperator is ","
cd $path_to_files
ls -lha | tail -n $number_of_files awk '{print $5}' >> names_of_data.csv
mv overview.csv $path_for_csv
"""

def NodeList():
    cmd = ["bash", "-c", "sinfo -N"]        #| grep -P \"alloc|mix\" | grep -P big | awk '{print $1}'"
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    Nodepanda = pd.read_csv(result.decode('utf-8'))
    return Nodepanda




old = subprocess.run(["bash", "-c", "sinfo | grep -P \"alloc|mix\" | grep -P big | awk '{print $6}'"])