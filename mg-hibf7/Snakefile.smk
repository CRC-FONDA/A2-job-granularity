import csv
import random
from collections import defaultdict
import subprocess
import os

configfile: "config.yaml"

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
    #  rule 