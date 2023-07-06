import csv
import random
from collections import defaultdict
import subprocess
import os

configfile: "config.yaml"

num_bins = 0 # will be read implicitly from the bins file
bins = defaultdict(lambda: [])

with open("data/bins.tsv", "r") as f:
    reader = csv.reader(f, delimiter='\t')

    for row in reader:
        filename = row[0]
        bin_id = int(row[1])
        bins[bin_id].append(filename)
        num_bins = max(num_bins, bin_id + 1)

if list(range(num_bins)) != list(bins.keys()):
    raise RuntimeError("Error bins.tsv")

bin_ids = range(num_bins)


cmd = ["bash", "-c", "sinfo --long --Node | grep -P idle | grep -P big | awk '{print $1}' > nodes.csv"]
subprocess.run(cmd)
list_of_nodes = []
nodes = {}

with open("nodes.csv", "r") as f:
    reader = csv.reader(f, delimiter=',')

    for row in reader:
        list_of_nodes.append(row[0])

for i in bin_ids:
    nodes[i] = random.choice(list_of_nodes)


with open("nodelist.csv", "w+") as f:
    writer = csv.writer(f, delimiter=',')
    for b, node in nodes.items():
        writer.writerow( [b, node] )

genome_bin_files = expand("data/genome_bins/bin_{bin_id}.fasta", bin_id=bin_ids)
distributed_read_files = expand("data/distributed_reads/bin_{bin_id}.fastq", bin_id=bin_ids)

for key, value in nodes:
    subprocess.run()

rule all:
    input:
        expand("data/mapped_reads/bin_{bin_id}.sam", bin_id=bin_ids)
    resources:
        nodelist = random.choice(list_of_nodes)
	shell:
		"echo 'Finished'"



# rule cplex_model:
#     input:
#         "all the genomes"
#     output:
#         "bins.tsv"


# rule prefilter:
    # rule raptor layout:
    # rule raptor build:
    # rule raptor search:
    # rule query_distributor:

# rule postprocessing:
    # rule samtools merge:
    # rule samtools sort:
    # rule samtools view:

# rule readmapping:
    # rule bwa2-mem-index
    # rule bwa2-mem 