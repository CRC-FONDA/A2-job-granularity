#Testfile for changing Parameters in the Workflow

import subprocess
import pandas as pd
import numpy as np
import random as r

#Loading available Nodes
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
#     Nodepanda = pd.read(result.decode('utf-8'))
#     return Nodepanda

# def change_config()

#     with open ('../simulation_config.yaml', 'w') as f:
#         config_file = yaml.load(f)
#         config_file['number_of_bins'] = n  



# for n in range(NodeList().length()):


# subprocess.run(["bash", "-c", "sinfo | grep -P \"alloc|mix\" | grep -P big | awk '{print $6}'"])