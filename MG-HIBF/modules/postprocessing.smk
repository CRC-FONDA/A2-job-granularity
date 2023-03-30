# convert .sam to .bam
rule samtools_view:
    input: 
        "data/mapped_reads/bin_{bin_id}.sam"
    output:
        temp("data/mapped_reads/bin_{bin_id}.bam")
    log:
        "logs/postprocessing/samtools_view/bin_{bin_id}.log"
    benchmark:
        "benchmarks/postprocessing/samtools_view/bin_{bin_id}.txt"
    resources:
        nodelist = lambda wildcards: nodes[int(wildcards.bin_id)]
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools view -b {input} -o {output} 2> {log}"

# sort .bam files by leftmost coordinates
rule samtools_sort:
    input:
        "data/mapped_reads/bin_{bin_id}.bam"
    output:
        temp("data/mapped_reads/bin_{bin_id}_sorted.bam")
    log:
        "logs/postprocessing/samtools_sort/bin_{bin_id}.log"
    resources:
        nodelist = lambda wildcards: nodes[int(wildcards.bin_id)]
    benchmark:
        "benchmarks/postprocessing/samtools_sort/bin_{bin_id}.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools sort {input} -o {output} 2> {log}"

# merge all .bam files
rule samtools_merge:
    input:
        expand("data/mapped_reads/bin_{bin_id}_sorted.bam", bin_id=range(num_bins))
    output:
        "data/mapped_reads/all.bam"
    threads:
        num_threads - 1 # they want the number of threads additional to the main thread
    log:
        "logs/postprocessing/samtools_merge.log"
    benchmark:
        "benchmarks/postprocessing/samtools_merge.txt"
    resources:
        nodelist = lambda wildcards: nodes[int(wildcards.bin_id)]
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools merge --threads {threads} {output} {input} 2> {log}"
