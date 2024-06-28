#-----------------------------
#
# sam to bam and sorting
#
#-----------------------------

rule samtools_convert:
	input:
		"data/mapped_reads/sam_{bin_id}.sam"
	output:
		temp("data/mapped_reads/bam_{bin_id}.bam")
	log:
        "logs/samtools_view/bin_{bin_id}.log"
    benchmark:
        "benchmarks/samtools_view/bin_{bin_id}.txt"
	conda:
		"../../envs/samtools.yaml"
	shell:
		"samtools view -bS {input} -o {output} 2> {log}"


rule samtools_sort:
	input: 
		"data/mapped_reads/bam_{bin_id}.bam"
	output:
		temp("data/mapped_reads/sortedbam_{bin_id}.sorted.bam")
	log:
        "logs/samtools_sort/bin_{bin_id}.log"
    benchmark:
        "benchmarks/samtools_sort/bin_{bin_id}.txt"
	shell:
		"samtools sort {input} -o {output} 2> {log}"

#-----------------------------
#
# adding groups for annotation
#
#-----------------------------
rule add_groups:
	input:
		"data/mapped_reads/sortedbam_{bin_id}.sorted.bam"
	output:
		temp("data/mapped_reads/with_groups_{bin_id}.sorted.bam")
	shell:
		"java -jar /software/picard.jar AddOrReplaceReadGroups" 
		"I={input.sortedfiles} O={output.with_groups}"
		"RGID=4 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=20"

#-----------------------------
#
# gather again 
# & index for faster access
#
#-----------------------------
rule samtools_merge:
    input:
        "data/mapped_reads/with_groups_{bin_id}.sorted.bam"
    output:
        temp("data/mapped_reads/all.bam")
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

