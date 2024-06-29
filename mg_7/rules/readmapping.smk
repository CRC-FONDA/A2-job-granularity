#-----------------------------
#
# building index for mapping
#
#-----------------------------

rule bwa_mem2_index:
    input:
        expand("data/bin_{i}/all{i}.fasta")
    output:
       expand("data/bin_{i}/index{i}", i=range(config['number_of_bins']))
    log:
        expand("logs/readmapping/bwa_mem2_index{i}.log")
    benchmark:
        repeat("benchmarks/readmapping/bwa_mem2_index{i}.tsv", 2)
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        """
        bwa-mem2 index \
        -t {threads} \
        -p {output} \
        {input} \
        > {log} 2>&1
        """

#-----------------------------
#
# readmapping
#
#-----------------------------
rule bwa_mem2_mem:
    input:
        index = expand("data/bin_{i}/index{i}")
        reads = expand("data/bin_{i}/all{i}.fasta")
    output:
        temp("data/bin_{i}/mapped_reads/sam_{i}.sam", i=range(config['number_of_bins'],-1,-1) )
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    log:
        expand("logs/readmapping/bwa_mem2_mem{i}.log")
    benchmark:
        expand("benchmarks/readmapping/bwa_mem2_mem{i}.tsv", 2)
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