# build an (fm-)index for every genome bin
#TODO, ressources: with variable from bins.tsv (variable = name of node)
rule bwa_mem2_index:
    input:
        "data/genome_bins/bin_{bin_id}.fasta"
    output:
        "data/indices/bin_{bin_id}_index"
    log:
        "logs/readmapping/bwa_mem2_index/bin_{bin_id}.log"
    benchmark:
        repeat("bwa-mem2-index-bin_{bin_id}.tsv", 2)
    resources:
        nodelist = nodes[bin_id]
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
    output:
        "data/mapped_reads/bin_{bin_id}.sam"
    threads:
        num_threads
    log:
        "logs/readmapping/bwa_mem2_mem/bin_{bin_id}.log"
    benchmark:
        "benchmarks/readmapping/bwa_mem2_mem/bin_{bin_id}.txt"
    resources:
        nodelist = nodes[bin_id]
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        "bwa-mem2 mem "
        "-t {threads} "
        "{input.index_prefix} "
        "{input.reads} "
        "> {output} "
        "2> {log}"
