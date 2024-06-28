#-----------------------------
#
# preparing the next scatter
#
#-----------------------------
rule list_of_chr:
    input:
        "data/mapped_reads/all.bam"
    output:
        "data/mapped_reads/chr.csv"
    shell:
        "samtools coverage {input} | awk '{print $1}' > {output}"


list_of_chromosomes = []

rule making_list:
    input:
        "data/mapped_reads/chr.csv"
    output:
        "data/mapped_reads/dummy"
    run:
        import subprocess
        import csv

        # list_of_chromosomes = []

        with open({input}, "r") as f:
            reader = csv.reader(f, delimiter=',')

            for row in reader:
                list_of_chromosomes.append row[0]

        cmd = ["echo 'dummy' > {output}"]
        subprocess.run(cmd, shell=True)



#-----------------------------
#
# searching for SNP's 
# scattered by chromosomes
#
#-----------------------------

rule Haplotypes:
    input:
        dummy = "data/mapped_reads/dummy",
        reference = config['reference_genome'],
        bam_all = "data/mapped_reads/all.bam"
    output:
        expand("data/Haplotypes/{chr}.vcf", chr=list_of_chromosomes)
    shell:
        "gatk --java-options '-Xmx10G' HaplotypeCaller"
        " -R {input.reference}"
        " -I {input.bam_all}"
        " -O {output}"
        " -L {wildcards.chr}"

#-----------------------------
#
# gather and filter
#
#-----------------------------
rule concate_Haplotypes:
    input:
        expand("data/Haplotypes/{chr}.vcf", chr=list_of_chromosomes)
    output:
        "data/Haplotypes/merged.vcf"
    shell:
        "bcftools concat --threads 10 {input} -o merged.vcf"

rule filter_Haplotypes:
    input:
        "data/Haplotypes/merged.vcf"
    output:
        "data/Haplotypes/filtered.vcf"
    shell:
        "bcftools view -v snps {input} -o {output}"


#-----------------------------
#
# annotate with database
#
#-----------------------------
rule SNP_Annotation:
    input:
        reference = config['reference_genome'],
        bam_all = "data/mapped_reads/all.bam",
        SNPs = "data/Haplotypes/filtered.vcf",
        dbsnp = config['database_SNPs']
    output:
        "data/Haplotypes/Annotation.vcf"
    shell:
        'gatk --java-options "-Xmx100G -XX:+UseParallelGC -XX:ParallelGCThreads=32"'
        'VariantAnnotator'
        ' -R {input.reference}'
        ' -I {input.bam_all}'
        ' -V {input.SNPs}'
        ' -O {output}'
        ' -A Coverage'
        ' --dbsnp {input.dbsnp}'