# all parameters are set in config.yaml
# these parameters describe the search
k = config["kmer_length"]
ep = round(config["allowed_errors"] / rl * 100) 		# percentage of errors allowed in an approximate match (int)
sp = round(config["strata_width"] / rl * 100)			# percentage of errors from the optimal alignment

#print("Percentage of errors: ", ep)
#print("Percentage of errors from the optimal alignment: ", sp)
 
# This file contains distributed read mapping for simulated data. Simulated data was already created in bins.

# create FM-indices for each bin
rule FM_index:
	input:
		bins = expand("../data/MG-2/" + str(bin_nr) + "/bins/{bin}.fasta", bin = bin_list)
	output:
		expand("fm_indices/{bin}.sa.val", bin = bin_list)
	params:
		outdir = "fm_indices/",
		t = 8
	shell:
		"dream_yara_indexer --threads {params.t} --output-prefix {params.outdir} {input.bins}"


# call bash script that acts as read mapping distributor
rule search_distributor:
	input:
		matches = "hashmap/all.output",
		all = "../data/MG-2/" + str(bin_nr) + "/reads_e" + str(epr) + "_" + str(rl) + "/all.fastq"
	output:
		expand("distributed_reads/{bin}.fastq", bin = bin_list)
	shell:
		"./scripts/search_distributor.sh {input.matches} {input.all} {bin_nr}"

# map reads to bins that were determined by the hashmap k-mer lemma filter
rule yara_mapper:
	input:
		reads = "distributed_reads/{bin}.fastq",
		index = "fm_indices/{bin}.sa.val"
	output:
		"mapped_reads/{bin}.sam"
	conda:
		"../../envs/yara.yaml"
	params:
		prefix = "fm_indices/{bin}",
	shell:
		"""
		# strata mapping mode
		yara_mapper -e {ep} -s {sp} -y full -sm record -o {output} {params.prefix} {input.reads}

		# clean up distributed mapping bins
		rm {input.reads}
		"""
