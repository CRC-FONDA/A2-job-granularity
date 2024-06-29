#-----------------------------
#
# sam to bam and sorting
#
#-----------------------------

rule samtools_convert:
    input:
        expand("data/bin_{i}/mapped_reads/sam_{i}.sam")
    output:
        temp("data/bin_{i}/mapped_reads/bam_{i}.bam", i=range(config['number_of_bins']))
    log:
        expand("logs/samtools_view{i}.log")
    benchmark:
        expand("benchmarks/samtools_view{i}.txt", 2)
    resources:
        nodes = config['number_of_nodes']
        threds = config['number_of_threads']
    conda:
        "../../envs/samtools.yaml"
    shell:
        "samtools view -bS {input} -o {output} 2> {log}"


#-----------------------------
#
# gather again 
# & index for faster access
#
#-----------------------------
rule samtools_merge:
    input:
        expand("data/mapped_reads/with_groups_{i}.sorted.bam")
    output:
        temp("data/mapped_reads/all.bam", i=range(config['number_of_bins']) )
    threads:
        config['threads']
    log:
        "logs/samtools_merge.log"
    benchmark:
        "benchmarks/samtools_merge.txt"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools merge --threads {threads} {output} {input} 2> {log}"

rule samtools_index:
    input: 
        "data/mapped_reads/all.bam"
    output:
        temp("data/mapped_reads/all.sorted.bam.bai")
    shell:
        "samtools index {input} {output}"


# rule samtools_sort:
#     input: 
#         expand("data/bin_{i}/mapped_reads/bam_{i}.bam")
#     output:
#         temp("data/bin_{i}/mapped_reads/sortedbam_{i}.sorted.bam", i=range(config['number_of_bins']))
#     log:
#         expand("logs/samtools_sort/bin_{i}.log")
#     resources:
#         nodes = config['number_of_nodes']
#         threds = config['number_of_threads']    
#     benchmark:
#         expand("benchmarks/samtools_sort/bin_{i}.txt")
#     shell:
#         "samtools sort {input} -o {output} 2> {log}"

#-----------------------------
#
# adding groups for annotation
# and indexing
#
#-----------------------------
# rule add_groups:
#     input:
#         expand("data/bin_{i}/mapped_reads/sortedbam_{i}.sorted.bam")
#     output:
#         temp("data/bin_{i}/mapped_reads/with_groups_{i}.sorted.bam", i=range(config['number_of_bins']))
#     resources:
#         nodes = config['number_of_nodes']
#     shell:
#         "java -jar /software/picard.jar AddOrReplaceReadGroups" 
#         "I={input} O={output}"
#         "RGID=4 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=20"


# rule samtools_index_bam:
#     input: 
#         expand("data/bin_{i}/mapped_reads/sortedbam_{i}.sorted.bam")
#     output:
#         temp("data/bin_{i}/mapped_reads/sortedbam_{i}.sorted.bam.bai", i=range(config['number_of_bins']))
#     resources:
#         nodes = config['number_of_nodes']
#         threds = config['number_of_threads']
#     shell:
#         "samtools index {input} {output}"