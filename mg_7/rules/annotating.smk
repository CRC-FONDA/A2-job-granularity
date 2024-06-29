#-----------------------------
#
# preparing the next scatter
#
#-----------------------------
# rule list_of_chr:
#     input:
#         expand("data/bin_{i}/mapped_reads/with_groups_{i}.sorted.bam")
#     output:
#         expand("data/bin_{i}/mapped_reads/chr.csv", i=range(config['number_of_bins']))
#     resources:
#         nodes = config['number_of_nodes']
#         threads = config['threads']
#     shell:
#         "samtools coverage {input} | awk '{{print $1}}' > {output}"


# rule making_list:
#     input:
#         expand("data/bin_{i}/mapped_reads/chr.csv")
#     output:
#         expand("data/bin_{i}/mapped_reads/dummy", i=range(config['number_of_bins']))
#     run:
#         with open({input}, "r") as f:
#             reader = csv.reader(f, delimiter=',')

#             for row in reader:
#                 list_of_chromosomes[].append(row[0])

#         cmd = ["echo 'dummy' > {output}"]
#         subprocess.run(cmd, shell=True)



#-----------------------------
#
# searching for SNP's 
# scattered by chromosomes
#
#-----------------------------


rule Haplotypes:
    input:
        reference = expand("data/bin_{i}/all{i}.fasta"),
        bam_all = expand("data/bin_{i}/mapped_reads/with_groups_{i}.sorted.bam", i=range(config['number_of_bins']))
    output:
        expand("data/bin_{i}/Haplotypes/merged.vcf", i=range(config['number_of_bins']))
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    run:
        """
        samtools coverage alignment.bam | \
        awk '{{print $1}}' | \
        parallel gatk --java-options '-Xmx10G' HaplotypeCaller \
         -R {input.reference} \
        -I {input.bam_all} -O \
        {.}.vcf -L {}

        bcftools concat --threads {resources.threads} *.vcf -o {output}
        """

#-----------------------------
#
# gather and filter
#
#-----------------------------

rule filter_Haplotypes:
    input:
        expand("data/bin_{i}/Haplotypes/merged.vcf")
    output:
        expand("data/bin_{i}/Haplotypes/filtered.vcf", i=range(config['number_of_bins']))
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    shell:
        "bcftools view -v snps {input} -o {output}"


#-----------------------------
#
# annotate with database
#
#-----------------------------
rule SNP_Annotation:
    input:
        reference = expand("data/bin_{i}/all{i}.fasta"),
        bam_all = expand("data/bin_{i}/mapped_reads/with_groups_{i}.sorted.bam"),
        SNPs = expand("data/bin_{i}/Haplotypes/filtered.vcf"),
        dbsnp = config['database_SNPs']
    output:
        expand("data/bin_{i}/Haplotypes/Annotation.vcf", i=range(config['number_of_bins']))
    resources:
        nodes = config['number_of_nodes']
        threads = config['threads']
    shell:
        'gatk --java-options "-Xmx100G -XX:+UseParallelGC -XX:ParallelGCThreads=32"'
        'VariantAnnotator'
        ' -R {input.reference}'
        ' -I {input.bam_all}'
        ' -V {input.SNPs}'
        ' -O {output}'
        ' -A Coverage'
        ' --dbsnp {input.dbsnp}'