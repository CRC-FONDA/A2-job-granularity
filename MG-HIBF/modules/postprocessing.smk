# convert .sam to .bam
rule samtools_view:
    input: 
        "data/mapped_reads/{genome_fasta_file}.sam"
    output:
        temp("data/mapped_reads/{genome_fasta_file}.bam")
    log:
        "logs/postprocessing/samtools_view/{genome_fasta_file}.log"
    benchmark:
        "benchmarks/postprocessing/samtools_view/{genome_fasta_file}.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools view -b {input} -o {output} 2> {log}"

# sort .bam files by leftmost coordinates
rule samtools_sort:
    input:
        "data/mapped_reads/{genome_fasta_file}.bam"
    output:
        temp("data/mapped_reads/{genome_fasta_file}_sorted.bam")
    log:
        "logs/postprocessing/samtools_sort/{genome_fasta_file}.log"
    benchmark:
        "benchmarks/postprocessing/samtools_sort/{genome_fasta_file}.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools sort {input} -o {output} 2> {log}"

# merge all .bam files
rule samtools_merge:
    input:
        expand("data/mapped_reads/{genome_fasta_file}_sorted.bam", genome_fasta_file=genome_fasta_files)
    output:
        "data/mapped_reads/all.bam"
    threads:
        num_threads - 1 # they want the number of threads additional to the main thread
    log:
        "logs/postprocessing/samtools_merge.log"
    benchmark:
        "benchmarks/postprocessing/samtools_merge.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools merge --threads {threads} {output} {input} 2> {log}"
