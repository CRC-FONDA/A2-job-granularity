# Prefiltering and search parameters are set in search_config.yaml
configfile: "search_config.yaml"

# Parameters for prefiltering
k = config["kmer_length"]
nr_er = epr		# number of errors allowed in an approximate local match

# Create txt file with one bin file per line
# File order determines the bin number a read is assigned to
import pathlib

PWD = pathlib.Path().absolute()
bin_path_list = [str(PWD) + "/../data/MG-5/" + str(bin_nr) + "/bins/" + str(i) + ".fasta" for i in list(range(0,bin_nr))]
with open('metadata/bin_paths.txt', 'w') as f:
    for item in bin_path_list:
        f.write("%s\n" % item)

rule build_prefilter:
	input:
		paths = "metadata/bin_paths.txt",
		bins = expand("../data/MG-5/" + str(bin_nr) + "/bins/{bin}.fasta", bin = bin_list)
	output:
		"hashmap/filter"
	shell:
		"./../../low-memory-prefilter/build/bin/hashmap build --kmer {k} --output {output} {input.paths}"

rule search_prefilter:
	input:
		filter = "hashmap/filter",
		reads = "../data/MG-5/" + str(bin_nr) + "/reads_e" + str(epr) + "_" + str(rl) + "/all.fastq"
	output:
		"hashmap/all.output"
	params:
		t = 8
	shell:
		"./../../low-memory-prefilter/build/bin/hashmap search --threads {params.t} --error {nr_er} --hashmap {input.filter} --output {output} {input.reads}"
