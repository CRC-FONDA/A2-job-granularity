rule Haplotypes:
	input:
		reference = 
		with_groups = "data/mapped_reads/with_groups_{bin_id}.sorted.bam"
	output:
		SNPs = "data/mapped_reads/SNPs_{bin_id}.vcf.gz"
	shell:
		'gatk --java-options "-Xmx10G" HaplotypeCaller' 
		'-R {input.reference}'
		'-I {input.with_groups}'
		'-O {output}.SNPs}'


rule SNP_Annotation:
	input:
		reference = 
		with_groups = "data/mapped_reads/with_groups_{bin_id}.sorted.bam"
		SNPs = "data/mapped_reads/SNPs_{bin_id}.vcf.gz"
	output:
		Annotations = "data/mapped_reads/Annot_{bin_id}.vcf.gz"
	shell:
		'gatk --java-options "-Xmx100G -XX:+UseParallelGC -XX:ParallelGCThreads=32"'
		'VariantAnnotator'
		'-R {input.reference}'
		'-I {input.with_groups}'
		'-V {input.SNPs}'
		'-O {output.Annotations}'
		'-A Coverage'
		'--dbsnp /group/albi-praktikum2023/data/dbSNP/dbSNP.vcf.gz'