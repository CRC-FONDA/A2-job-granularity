#-----------------------------
#
# building index for mapping
#
#-----------------------------
# takes too long for a whole genome
# just use it on smaller samples

# rule bwa_mem2_index:
#     input:
#         ref = config['reference_genome']
#     output:
#         "data/readmapping/index"
#     log:
#         "logs/readmapping/bwa_mem2_index.log"
#     conda:
#         "../envs/bwa-mem2.yaml"
#     threads: 
#         config['threads']
#     shell:
#         """
#         bwa-mem2 index \
#         -t {threads} \
#         -p {output} \
#         {input.ref} \
#         > {log} 2>&1
#         """

#-----------------------------
#
# building the bins
#
#-----------------------------


#-----------------------------
#
# readmapping
#
#-----------------------------
rule bwa_mem2_mem:
    input:
        index = "data/readmapping/index",
        reads = expand("data/bin_{i}/{reads}", reads=filepaths_bins[i])  #i=range(config['number_of_bins']),
    output:
        temp("data/mapped_reads/sam_{i}.sam", i=range(config['number_of_bins']) )
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    log:
        expand("logs/readmapping/bwa_mem2_mem/bin_{bins}.log")
    benchmark:
        expand("benchmarks/readmapping/bwa_mem2_mem/bin_{bins}.txt")
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        """
        bwa-mem2 mem \
        -t {resources.threads} \
        {input.index} \
        {input.reads} \
        > {output} \
        2> {log}
        """