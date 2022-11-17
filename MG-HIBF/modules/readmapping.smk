# build an index for every genome
rule bwa_mem2_index:
    input:
        "data/genome_bins/bin_{bin_id}.fasta"
    output:
        "data/indices/bin_{bin_id}_index",
    log:
        "logs/readmapping/bwa_mem2_index/bin_{bin_id}.log"
    benchmark:
        "benchmarks/readmapping/bwa_mem2_index/bin_{bin_id}.txt"
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        # the touch output is as a marker for snakemake that the rule is completed
        "bwa-mem2 index "
        "-p {output} "
        "{input} "
        "> {log} 2>&1 "
        "&& touch {output}"

# map all the reads at once on every genome using its built index
# version without filter
# rule bwa_mem2_mem:
#     input:
#         index_prefix="data/indices/bin_{bin_id}_index",
#         reads="data/queries.fastq"
#     output:
#         temp("data/mapped_reads/bin_{bin_id}.sam")
#     threads:
#         num_threads
#     log:
#         "logs/readmapping/bwa_mem2_mem/bin_{bin_id}.log"
#     benchmark:
#         "benchmarks/readmapping/bwa_mem2_mem/bin_{bin_id}.txt"
#     conda:
#         "envs/bwa-mem2.yaml"
#     shell:
#         "bwa-mem2 mem "
#         "-t {threads} "
#         "{input.index_prefix} "
#         "{input.reads} "
#         "> {output} "
#         "2> {log}"

# readmapping version with filter
rule bwa_mem2_mem:
    input:
        index_prefix="data/indices/bin_{bin_id}_index",
        reads="data/distributed_reads/bin_{bin_id}.fastq"
    output:
        temp("data/mapped_reads/bin_{bin_id}.sam")
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
