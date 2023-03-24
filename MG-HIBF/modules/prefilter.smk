# collect all filenames of the reference genomes into a file that is the input for chopper count
# every genome in every file then is a bin for the filter (HIBF)
rule write_bin_list:
    input:
        genome_bin_files
    output:
        "data/genome_bins/list.tsv"
    run:
        bin_file_str = '\n'.join(input)
        with open("data/genome_bins/list.tsv", "w+") as f:
            f.write(bin_file_str)

prefilter_config = config["prefilter"]
chopper_config = prefilter_config["chopper"]
raptor_config = prefilter_config["raptor"]

# count kmers in the reference genomes
rule chopper_count:
    input:
        file_list="data/genome_bins/list.tsv",
        dummies=genome_bin_files
    output:
        "data/prefilter/hibf.layout"
    params:
        k=prefilter_config["kmer_size"],
        tmax=chopper_config["tmax"],
        h=prefilter_config["num_hash_functions"],
        fpr=prefilter_config["false_positive_rate"],
    threads:
        num_threads
    log:
        "logs/prefilter/raptor_layout.log"
    benchmark:
        "benchmarks/prefilter/raptor_layout.txt"
    resources:
        nodelist = nodes[bin_id]
    shell:
        "./tools/raptor/build/bin/raptor layout "
        "--input-file {input.file_list} "
        "--kmer-size {params.k} "
        "--tmax {params.tmax} "
        "--num-hash-functions {params.h} "
        "--false-positive-rate {params.fpr} "
        "--output-filename {output} "
        "--rearrange-user-bins "
        "--threads {threads} "
        "2> {log}"

# # use kmer counts to construct the filter layout
# rule chopper_layout:
#     input:
#         chopper_count_output_file
#     output:
#         "data/prefilter/hibf.layout"
#     params:
#         tmax=chopper_config["tmax"],
#         h=prefilter_config["num_hash_functions"],
#         fpr=prefilter_config["false_positive_rate"],
#         in_prefix=chopper_count_output_prefix
#     threads:
#         num_threads
#     log:
#         "logs/prefilter/chopper_layout.log"
#     benchmark:
#         "benchmarks/prefilter/chopper_layout.txt"
#     shell:
#         "./tools/raptor/build/bin/chopper layout "
#         "--tmax {params.tmax} "
#         "--num-hash-functions {params.h} "
#         "--false-positive-rate {params.fpr} "
#         "--input-prefix {params.in_prefix} "
#         "--output-filename {output} "
#         "--rearrange-user-bins "
#         "--threads {threads} "
#         "2> {log}"

# build the query prefilter
rule raptor_build:
    input:
        layout="data/prefilter/hibf.layout",
        dummies=genome_bin_files
    output:
        "data/prefilter/hibf.index"
    params:
        k=prefilter_config["kmer_size"],
        h=prefilter_config["num_hash_functions"],
        fpr=prefilter_config["false_positive_rate"]
    threads:
        num_threads
    log:
        "logs/prefilter/raptor_build.log"
    benchmark:
        "benchmarks/prefilter/raptor_build.txt"
    resources:
        nodelist = nodes[bin_id]
    shell:
        "./tools/raptor/build/bin/raptor build "
        "--kmer {params.k} "
        "--window {params.k} "
        "--hash {params.h} "
        "--fpr {params.fpr} "
        "--hibf {input.layout} "
        "--output {output} "
        "--threads {threads} "
        "2> {log}"

# classify the reads into the bins
rule raptor_search:
    input:
        index="data/prefilter/hibf.index",
        read_queries="data/queries.fastq"
    output:
        "data/prefilter/search.out"
    params:
        fpr=prefilter_config["false_positive_rate"],
        err=raptor_config["num_errors"],
        pmax=raptor_config["pmax"],
        tau=raptor_config["tau"]
    threads:
        num_threads
    log:
        "logs/prefilter/raptor_search.log"
    benchmark:
        "benchmarks/prefilter/raptor_search.txt"
    resources:
        nodelist = nodes[bin_id]
    shell:
        "./tools/raptor/build/bin/raptor search "
        "--index {input.index} "
        "--query {input.read_queries} "
        "--output {output} "
        "--fpr {params.fpr} "
        "--error {params.err} "
        "--threads {threads} "
        "--p_max {params.pmax} "
        "--tau {params.tau} "
        "--hibf "
        "2> {log}"

# write a .fastq for every genome bin with the reads it could contain
# according to the raptor search output
rule query_distributor:
    input:
        raptor="data/prefilter/search.out",
        read_queries="data/queries.fastq"
    output:
        temp(distributed_read_files)
    log:
        "logs/prefilter/query_distributor.log"
    benchmark:
        "benchmarks/prefilter/query_distributor.txt"
    resources:
        nodelist = nodes[bin_id]
    shell:
        "tools/query-distributor/target/release/query-distributor "
        "--raptor-search-output {input.raptor} "
        "--queries {input.read_queries} "
        "--output-folder data/distributed_reads/ "
        "2> {log}"
