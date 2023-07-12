import csv
import numpy as np
import os
from pathlib import Path
import pandas as pd
import sys
import subprocess

path_to_dir = Path(sys.argv[1])
name = str(sys.argv[2]).lower()

filenames = filter(lambda x: name in x.lower(), os.listdir(path_to_dir))
paths = map((lambda x: path_to_dir / x), filenames)

final_name = Path(path_to_dir / ("general_results_" + name + ".tsv"))
filenames = filter(lambda x: final_name not in x, paths)

data = pd.read_csv(final_name, sep='\t')

for _ in paths:
    print(_)
    f = pd.read_csv(_, sep='\t')
    f = f.replace("", np.nan, inplace=True)
    f = f.dropna(how='any').drop("bin_id", axis=1)
    f["Nodes"] = f["Nodes"].str.replace('cmp', "").astype(int)
    data = data.append(f, ignore_index=True)
    
data.to_csv(final_name, index=False, sep='\t')