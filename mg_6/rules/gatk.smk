rule Haplotypes:
	input:
		reference = config['database_SNPs'],
		with_groups = "data/mapped_reads/all.bam"
	output:
		"data/mapped_reads/SNPs.vcf.gz"
	shell:
		'gatk --java-options "-Xmx10G" HaplotypeCaller' 
		'-R {input.reference}'
		'-I {input.with_groups}'
		'-O {output}'


rule SNP_Annotation:
	input:
		reference = config['database_SNPs'],
		with_groups = "data/mapped_reads/all.bam",
		SNPs = "data/mapped_reads/SNPs.vcf.gz",
		chromosomes = ""
	output:
		"data/mapped_reads/Annotation_{chr}.vcf.gz", chr=
	shell:
		'gatk --java-options "-Xmx100G -XX:+UseParallelGC -XX:ParallelGCThreads=32"'
		'VariantAnnotator'
		'-R {input.reference}'
		'-I {input.with_groups}'
		'-V {input.SNPs}'
		'-O {output.Annotations}'
		'-A Coverage'
		'--dbsnp {input.reference}'
		'-L {input.chromosomes}'