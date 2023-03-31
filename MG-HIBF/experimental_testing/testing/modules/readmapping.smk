# build an (fm-)index for every genome bin
#TODO, ressources: with variable from bins.tsv (variable = name of node)
rule bwa_mem2_index:
	input:
		"data/genome_bins/bin_{bin_id}.fasta"
	output:
		"data/indices/bin_{bin_id}_index",	
	log:
		"logs/readmapping/bwa_mem2_index/bin_{bin_id}.log"
    #threads: 10
	benchmark:
		repeat("bwa-mem2-index-bin_{bin_id}.tsv",2)
	resources:
		#nodelist= lambda wildcards: "cmp[247]" if int(wildcards.bin_id)==0 else "cmp[248]" 
		#nodelist= lambda wildcards: "cmp[247]" if int(wildcards.bin_id)<=1 else "cmp[248]"
		#nodelist= lambda wildcards: "cmp[247]" if int(wildcards.bin_id)==0 else("cmp[248]" if int(wildcards.bin_id)==1 else("cmp[201]" if int(wildcards.bin_id)==2 else "cmp[202]"))
		nodelist= lambda wildcards: "cmp[248]" if int(wildcards.bin_id)==0
			 else ("cmp[248]" if int(wildcards.bin_id)==1 
			 else ("cmp[248]" if int(wildcards.bin_id)==2 
			#else ( "cmp[248]" if int(wildcards.bin_id)==3 
			#else ("cmp[207]" if int(wildcards.bin_id)==4 
			#else ("cmp[208]" if int(wildcards.bin_id)==5 
			#else ("cmp[209]" if int(wildcards.bin_id)==6 
			#else ("cmp[211]" if int(wildcards.bin_id)==7 
			#else ("cmp[212]" if int(wildcards.bin_id)==8 
			#else ("cmp[213]" if int(wildcards.bin_id)==9 
			#else ("cmp[215]" if int(wildcards.bin_id)==10 
			#else ("cmp[216]" if int(wildcards.bin_id)==11 
			#else ( "cmp[218]" if int(wildcards.bin_id)==12 
			#else("cmp[201]" if int(wildcards.bin_id)==13 
			#else("cmp[202]" if int(wildcards.bin_id)==14
			#else("cmp[204]" if int(wildcards.bin_id)==15 
			#else( "cmp[206]" if int(wildcards.bin_id)==16 
			#else("cmp[207]" if int(wildcards.bin_id)==17 
			#else ("cmp[208]" if int(wildcards.bin_id)==18 
			#else ("cmp[209]" if int(wildcards.bin_id)==19 
			#else("cmp[211]" if int(wildcards.bin_id)==20 
			#else("cmp[212]" if int(wildcards.bin_id)==21 
			#else("cmp[213]" if int(wildcards.bin_id)==22 
			#else("cmp[215]" if int(wildcards.bin_id)==23 
			#else("cmp[216]" if int(wildcards.bin_id)==24  
			 else "cmp[217]"))
	#)) ) ))) ) ) )
	conda:
		"../envs/bwa-mem2.yaml" 
	shell:
        # the touch output is as a marker for snakemake that the rule is completed
		"bwa-mem2 index "
		"-p {output} "
		"{input} "
		"> {log} 2>&1 "
		"&& touch {output}"

# readmapping with filtered input reads
rule bwa_mem2_mem:
	input:
		index_prefix="data/indices/bin_{bin_id}_index",
		reads="data/distributed_reads/bin_{bin_id}.fastq"
	# reads="data/queries.fastq" 
	output:
		"data/mapped_reads/bin_{bin_id}.sam"
	threads:
		num_threads
	log:
		"logs/readmapping/bwa_mem2_mem/bin_{bin_id}.log"
	benchmark:
		"benchmarks/readmapping/bwa_mem2_mem/bin_{bin_id}.txt"
	conda:
		"../envs/bwa-mem2.yaml"
	shell:
		"bwa-mem2 mem "
		"-t {threads} "
		"{input.index_prefix} "
		"{input.reads} "
		"> {output} "
		"2> {log}"
