#-----------------------------
#
# sam to bam and sorting
#
#-----------------------------

rule samtools_convert:
    input:
        expand("data/mapped_reads/sam_{i}.sam")
    output:
        temp("data/mapped_reads/bam_{i}.bam", i=bin_list)
    log:
        expand("logs/samtools_view/bin_{i}.log")
    benchmark:
        expand("benchmarks/samtools_view/bin_{i}.txt")
    conda:
        "../../envs/samtools.yaml"
    shell:
        "samtools view -bS {input} -o {output} 2> {log}"


rule samtools_sort:
    input: 
        expand("data/mapped_reads/bam_{i}.bam", i=bin_list)
    output:
        temp("data/mapped_reads/sortedbam_{i}.sorted.bam")
    log:
        expand("logs/samtools_sort/bin_{i}.log")
    benchmark:
        expand("benchmarks/samtools_sort/bin_{i}.txt")
    shell:
        "samtools sort {input} -o {output} 2> {log}"

#-----------------------------
#
# adding groups for annotation
#
#-----------------------------
rule add_groups:
    input:
        expand("data/mapped_reads/sortedbam_{i}.sorted.bam")
    output:
        temp("data/mapped_reads/with_groups_{i}.sorted.bam", i=bin_list)
    shell:
        "java -jar /software/picard.jar AddOrReplaceReadGroups" 
        "I={input} O={output}"
        "RGID=4 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=20"

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
        temp("data/mapped_reads/all.bam", i=bin_list)
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

