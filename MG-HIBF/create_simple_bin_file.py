import os
import sys
import csv
import random
from pathlib import Path


folder_name = Path(sys.argv[1])
fasta_file_endings = [".fa", ".fna", ".fasta"]

is_fasta_file = lambda f: any(f.endswith(end) for end in fasta_file_endings)
fasta_filenames = filter(lambda f: is_fasta_file(f), os.listdir(folder_name))

to_path = lambda filename: folder_name / filename
fasta_paths = map(to_path, fasta_filenames)

nodelist = ["cmp247","cmp248","cmp201","cmp202","cmp203","cmp204","cmp205","cmp213","cmp214","cmp215","cmp216","cmp217","cmp218","cmp219","cmp220","cmp230"]
bin_size = int(sys.argv[2]) if len(sys.argv) > 2 else 1
nodedict = {}
for i in range(bin_size):
    nodedict[i] = random.choice(nodelist)

with open("bins.tsv", "w+") as f:
    writer = csv.writer(f, delimiter='\t')
    for i, fasta_path in enumerate(fasta_paths):
        writer.writerow( [fasta_path, int(i/bin_size),  nodedict[int(i/bin_size)]] )
