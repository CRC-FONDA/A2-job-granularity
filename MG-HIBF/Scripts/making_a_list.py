import os
import sys
import csv
import pandas as pd
"""
sinfo --long --Node | grep "small" | grep "mixed" | awk '{print $0}' >> nodelist.csv
"""

df = pd.read_csv('nodelist.csv')

conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
snakemake --help