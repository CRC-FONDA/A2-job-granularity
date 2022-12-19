import os
import sys
import csv
from pathlib import Path

folder_name = Path(sys.argv[1])
fasta_file_endings = [".fa", ".fna", ".fasta"]

is_fasta_file = lambda f: any(f.endswith(end) for end in fasta_file_endings)
fasta_filenames = filter(lambda f: is_fasta_file(f), os.listdir(folder_name))

to_path = lambda filename: folder_name / filename
fasta_paths = map(to_path, fasta_filenames)

bin_size = int(sys.argv[2]) if len(sys.argv) > 2 else 1
with open("bins.tsv", "w+") as f:
    writer = csv.writer(f, delimiter='\t')
    for i, fasta_path in enumerate(fasta_paths):
        writer.writerow([fasta_path, int(i / bin_size)])
