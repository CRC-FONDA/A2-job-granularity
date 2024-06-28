# buidling bins --> bin_id, filename
# building nodelist --> bin_id, nodename

import os
import csv
from pathlib import Path

# creating some wildcards
bin_size = int(config['files_per_bin'])
bin_list = list(range(bin_size))
bin_pathlist = [f"data/bin_{i}" for i in bin_list]
path_to_dir = config['path_to_data']

def create_bins_file(path_to_dir, bin_size):
    path_to_dir = Path(path_to_dir)

    fasta_file_endings = [".fa", ".fna", ".fasta", "fastqc"]

    is_fasta_file = lambda f: any(f.endswith(end) for end in fasta_file_endings)
    fasta_filenames = filter(lambda f: is_fasta_file(f), os.listdir(path_to_dir))

    to_path = lambda filename: path_to_dir / filename  
    fasta_paths = map(to_path, fasta_filenames)

    with open("data/general/bins.tsv", "w+") as f:
        writer = csv.writer(f, delimiter='\t')
        for i, fasta_path in enumerate(fasta_paths):
            writer.writerow( [fasta_path , (i//bin_size)] )


rule create_general_files:
    input:
        path_to_dir
    output:
        "data/general/bins.tsv",
        "data/general/nodes.csv"
    run:
        create_bins_file({input.path_to_dir}, {input.bin_size})
        shell("bash sinfo --long --Node | grep -P 'mix|idle' | grep -P big | awk '{print $1}' > data/general/nodes.csv")


filepaths_bins = defaultdict(lambda: [])

rule filepaths:
    input:
        "data/general/bins.tsv"
    output:
        directory({bin_pathlist})
    run:
        with open("data/bins.tsv", "r") as f:
            reader = csv.reader(f, delimiter='\t')

            for row in reader:
                filename = row[0]
                bin_id = int(row[1])
                filepaths_bins[bin_id].append(filename)




# rule set_up_data:
#     input:
#         "data/general/bins.tsv"
#     output:
#         expand("data/genome_bins/{bin_id}/", bin_id={wildcards.bin_list})
#     run:
#         # num_bins = 0
#         # bins = defaultdict(lambda: [])

#         # with open("data/bins.tsv", "r") as f:
#         #     reader = csv.reader(f, delimiter='\t')
            
#         #     for row in reader:
#         #         filename = row[0]
#         #         bin_id = int(row[1])
#         #         bins[bin_id].append(filename)
#         #         num_bins = max(num_bins, bin_id + 1)

#         # if list(range(num_bins)) != list(bins.keys()):
#         #     raise RuntimeError("Error bins.tsv")

#         # bin_ids = range(num_bins)


# rule creating_bin_files:
#     input:
#         "data/general/bins.tsv"

#     shell:
#         "for i in {input}; do echo $i >> {output}; done;"

# rule building_nodelist:
#     input: 
#         "data/general/nodes.csv"
#     output:
#         "data/general/nodelist.csv"
#     run:
#         list_of_nodes = []
#         nodes = {}

#         with open("data/genome_bins/nodes.csv", "r") as f:
#             reader = csv.reader(f, delimiter=',')
#             for row in reader:
#                 list_of_nodes.append(row[0])

#         for i in bin_ids:
#             nodes[i] = random.choice(list_of_nodes)

#         with open("data/genome_bins/nodelist.csv", "w+") as f:
#             writer = csv.writer(f, delimiter=',')
#             for b, node in nodes.items():
#                 writer.writerow( [b, node] )



# rule create_bin_directories:
#     input:
#         bin_size = int(config['files_per_bin'])
#         bin_list = list(range(bin_size))
#         bin_pathlist = [f"data/bin_{i}" for i in bin_list]
#     output:
#         expand("data/bin_{i}", i={input.bin_list})
#     run:
#         shell("mkdir -p data/general")

#         for b in {input.bin_pathlist}:
#             shell(f"mkdir -p {b}")