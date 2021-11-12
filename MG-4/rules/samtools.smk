# -----------------------------
# 
# Rule resources for sorting:
# m: max memory per thread in bytes (default is 500000000)
# t: threads (default single threaded)
#
# thread and memory parameters could also be added to the index and stats commands
# -----------------------------

rule samtools_merge:
	input:
		expand("mapped_reads/{read_file}.sam", read_file=read_list)
	output:
		"mapped_reads/all.sam"
	conda:
		"../../envs/samtools.yaml"
	shell:
		"""
		ulimit -n 2048
		samtools merge {input} -o {output}
		"""

rule samtools_collate:
	input:
		"mapped_reads/all.sam"
	output:
		"mapped_reads/all_sorted.sam"
	conda:
		"../../envs/samtools.yaml"
	shell:
		"samtools collate {input} -o {output}"

