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
    threads: 
        config['threads']
    shell:
        """
        bwa-mem2 index \
        -t {threads} \
        -p {output} \
        {input.ref} \
        > {log} 2>&1
        """

#-----------------------------
#
# building the bins
#
#-----------------------------
# rule copying_data_to_nodes:
#     input:
#         expand("{data}", data=bin_list)
#     output:
#         directory("data/bin_{bins}"),
#         expand("data/bin_{bins}/{reads}", bins="{bins}", reads=lambda wildcards: filepaths_bins[int(wildcards.bins)]))
#     shell:
#         "mkdir -p {output[0]} && cp {input} {output[0]}/"
#         " && ln -s {output[0]}/{wildcards.read} {output[1]}"  
#     # Create symbolic link
#     # Collect output files

# rule copying_data_to_nodes:
#     input:
#         expand("{data}", data=bin_list)
#     output:
#         directory("data/bin_{bins}"),
#         expand("data/bin_{bins}/{reads}", bins="{bins}", reads=lambda wildcards: filepaths_bins[int(wildcards.bins)])
#     shell:
#         """
#         mkdir -p {output[0]}
#         for file in {input}; do
#             cp $file {output[0]}/
#         done
#         """

rule copying_data_to_nodes:
    input:
        lambda wildcards: filepaths_bins[int(wildcards.bins)]
    output:
        directory("data/bin_{bins}"),
        expand("data/bin_{bins}/{reads}", bins="{bins}", reads=lambda wildcards: filepaths_bins[int(wildcards.bins)])
    shell:
        """
        mkdir -p {output[0]}
        for file in {input}; do
            cp $file {output[0]}/
        done
        """

#-----------------------------
#
# readmapping
#
#-----------------------------
# rule bwa_mem2_mem:
#     input:
#         index="data/readmapping/index",
#         reads="data/bin_{bins}/"
#     output:
#         temp("data/mapped_reads/sam_{bin_id}.sam")
#     threads:
#         config['threads']
#     log:
#         "logs/readmapping/bwa_mem2_mem/bin_{bin_id}.log"
#     benchmark:
#         "benchmarks/readmapping/bwa_mem2_mem/bin_{bin_id}.txt"
#     conda:
#         "../envs/bwa-mem2.yaml"
#     shell:
#         "bwa-mem2 mem "
#         "-t {threads} "
#         "{input.index}"
#         "{input.reads} "
#         "> {output} "
#         "2> {log}"

rule bwa_mem2_mem:
    input:
        index="data/readmapping/index",
        reads=lambda wildcards: expand("data/bin_{wildcards.bins}/{reads}", reads=filepaths_bins[int(wildcards.bins)])
    output:
        temp("data/mapped_reads/sam_{bins}.sam")
    threads:
        config['threads']
    log:
        "logs/readmapping/bwa_mem2_mem/bin_{bins}.log"
    benchmark:
        "benchmarks/readmapping/bwa_mem2_mem/bin_{bins}.txt"
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        """
        bwa-mem2 mem \
        -t {threads} \
        {input.index} \
        {input.reads} \
        > {output} \
        2> {log}
        """

