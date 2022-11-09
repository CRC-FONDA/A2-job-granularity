prefilter_config = config["prefilter"]
chopper_config = prefilter_config["chopper"]
raptor_config = prefilter_config["raptor"]

chopper_count_output_prefix = "data/prefilter/genomes"
chopper_count_output_file = chopper_count_output_prefix + ".count"

# collect all filenames of the reference genomes into a file that is the input for chopper count
# every genome in every file then is a bin for the filter (HIBF)
rule collect_filenames:
    input:
        "data/genomes"
    output:
        "data/genomes/list.tsv"
    shell:
        "find {input} -type f "
        "| grep -E '.+\.(fa|fna|fasta)' "
        "> {output}"

# count kmers in the reference genomes
rule chopper_count:
    input:
        "data/genomes/list.tsv"
    output:
        chopper_count_output_file
    params:
        k=prefilter_config["kmer_size"],
        out_prefix=chopper_count_output_prefix
    threads:
        num_threads
    log:
        "logs/prefilter/chopper_count.log"
    benchmark:
        "benchmarks/prefilter/chopper_count.txt"
    shell:
        "./tools/raptor/build/bin/chopper count "
        "--input-file {input} "
        "--output-prefix {params.out_prefix} "
        "--kmer-size {params.k} "
        "--threads {threads} "
        "2> {log}"

# use kmer counts to construct the filter layout
rule chopper_layout:
    input:
        chopper_count_output_file
    output:
        "data/prefilter/hibf.layout"
    params:
        tmax=chopper_config["tmax"],
        h=prefilter_config["num_hash_functions"],
        fpr=prefilter_config["false_positive_rate"],
        in_prefix=chopper_count_output_prefix
    threads:
        num_threads
    log:
        "logs/prefilter/chopper_layout.log"
    benchmark:
        "benchmarks/prefilter/chopper_layout.txt"
    shell:
        "./tools/raptor/build/bin/chopper layout "
        "--tmax {params.tmax} "
        "--num-hash-functions {params.h} "
        "--false-positive-rate {params.fpr} "
        "--input-prefix {params.in_prefix} "
        "--output-filename {output} "
        "--rearrange-user-bins "
        "--threads {threads} "
        "2> {log}"

# build the query prefilter
rule raptor_build:
    input:
        "data/prefilter/hibf.layout"
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
    shell:
        "./tools/raptor/build/bin/raptor build "
        "--kmer {params.k} "
        "--window {params.k} "
        "--hash {params.h} "
        "--fpr {params.fpr} "
        "--hibf {input} "
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
        temp(expand("data/distributed_queries/{genome_fasta_file}.fastq", genome_fasta_file=genome_fasta_files))
    log:
        "logs/prefilter/query_distributor.log"
    benchmark:
        "benchmarks/prefilter/query_distributor.txt"
    shell:
        "tools/query-distributor/target/release/query-distributor "
        "--raptor-search-output {input.raptor} "
        "--queries {input.read_queries} "
        "--output-folder data/distributed_queries/ "
        "2> {log}"
