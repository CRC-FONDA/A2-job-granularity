#-----------------------------
#
# building index for mapping
#
#-----------------------------
rule bwa_mem2_index:
    input:
        ref = config['reference_genome']
    output:
        "data/readmapping/index"
    log:
        "logs/readmapping/bwa_mem2_index.log"
    conda:
        "../envs/bwa-mem2.yaml"
    threads: config['threads']
    shell:
        # the touch output is as a marker for snakemake that the rule is completed
        "bwa-mem2 index "
        "-t {threads}"
        "-p {output} "
        "{input.ref} "
        "> {log} 2>&1 "
        "&& touch {output}"

#-----------------------------
#
# building the bins
#
#-----------------------------
rule copying_data_to_nodes:
    input:
        expand("{data}", data=bin_list)
    output:
        directory("data/bin_{bins}"),
        expand("data/bin_{bins}/{reads}", bins=bin_list, reads=filepaths_bins[bins])
    shell:
        "mkdir -p {output[0]} && cp {input} {output[0]}/"
        " && ln -s {output[0]}/{wildcards.read} {output[1]}"  
    # Create symbolic link
    # Collect output files


#-----------------------------
#
# readmapping
#
#-----------------------------
rule bwa_mem2_mem:
    input:
        index="data/readmapping/index",
        reads="data/bin_{bins}/"
    output:
        temp("data/mapped_reads/sam_{bin_id}.sam")
    threads:
        config['threads']
    log:
        "logs/readmapping/bwa_mem2_mem/bin_{bin_id}.log"
    benchmark:
        "benchmarks/readmapping/bwa_mem2_mem/bin_{bin_id}.txt"
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        "bwa-mem2 mem "
        "-t {threads} "
        "{input.index}"
        "{input.reads} "
        "> {output} "
        "2> {log}"
