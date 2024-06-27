
rule samtools_convert:
	input:
		samfiles = "data/mapped_reads/sam_{bin_id}.sam"
	output:
		bamfiles = "data/mapped_reads/bam_{bin_id}.bam"
	conda:
		"../../envs/samtools.yaml"
	shell:
		"samtools view -bS {input.samfiles} > {output.bamfiles}"
		"rm {input.samfiles}"

rule samtools_sort:
	input: 
		bamfiles = "data/mapped_reads/bam_{bin_id}.bam"
	output:
		sortedfiles = "data/mapped_reads/sortedbam_{bin_id}.sorted.bam"
	shell:
		"samtools sort {input.bamfiles} -o {output.sortedfiles}"


rule add_groups:
	input:
		sortedfiles = "data/mapped_reads/sortedbam_{bin_id}.sorted.bam"
	output:
		with_groups = "data/mapped_reads/with_groups_{bin_id}.sorted.bam"
	shell:
		"java -jar /software/picard.jar AddOrReplaceReadGroups" 
		"I={input.sortedfiles} O={output.with_groups}"
		"RGID=4 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=20"


rule samtools_index:
	input: 
		with_groups = "data/mapped_reads/with_groups_{bin_id}.sorted.bam"
	output:
		indexfiles = "data/mapped_reads/index_{bin_id}.sorted.bam.bai"
	shell:
		"samtools index {input.sortedfiles} {output.indexfiles}"


rule clean:
	input:
		sortedfiles = "data/mapped_reads/sortedbam_{bin_id}.sorted.bam"
		indexfiles = "data/mapped_reads/index_{bin_id}.sorted.bam.bai"
		bamfiles = "data/mapped_reads/bam_{bin_id}.bam"
		samfiles = "data/mapped_reads/sam_{bin_id}.sam"
	shell:
		"rm {input.bamfiles} {input.sortedfiles} {input.samfiles}"
