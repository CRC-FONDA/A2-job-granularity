
filepaths_bins = defaultdict(lambda: [])

#-----------------------------
#
# building index for mapping
#
#-----------------------------
rule bwa_mem2_index:
    input:
        ref = config['reference_genome']
    output:
        "data/readmapping/index"
    log:
        "logs/readmapping/bwa_mem2_index.log"
    conda:
        "../envs/bwa-mem2.yaml"
    threads: 
        config['threads']
    shell:
        """
        bwa-mem2 index \
        -t {threads} \
        -p {output} \
        {input.ref} \
        > {log} 2>&1
        """

#-----------------------------
#
# building the bins
#
#-----------------------------
rule copying_data_to_nodes:
    input:
        "data/general/bins.tsv",
    output:
        expand("data/bin_{i}", i=bin_list)
    run:
        import os
        import csv
        from collections import defaultdict

        filepaths_bins = defaultdict(lambda: [])

        with open("data/bins.tsv", "r") as f:
            reader = csv.reader(f, delimiter='\t')

            for row in reader:
                filename = row[0]
                bin_id = int(row[1])
                filepaths_bins[bin_id].append(filename)
        
        for bin_id in bin_list:
            bin_dir = f"data/bin_{bin_id}"
            os.makedirs(bin_dir, exist_ok=True)  # Create directory if it doesn't exist
            for file in filepaths_bins[bin_id]:
                os.system(f"cp {file} {bin_dir}/")


#-----------------------------
#
# readmapping
#
#-----------------------------
rule bwa_mem2_mem:
    input:
        index="data/readmapping/index",
        reads=lambda wildcards: expand("data/bin_{wildcards.bins}/{reads}", reads=filepaths_bins[int(wildcards.bins)])
    output:
        temp("data/mapped_reads/sam_{bins}.sam")
    threads:
        config['threads']
    log:
        "logs/readmapping/bwa_mem2_mem/bin_{bins}.log"
    benchmark:
        "benchmarks/readmapping/bwa_mem2_mem/bin_{bins}.txt"
    conda:
        "../envs/bwa-mem2.yaml"
    shell:
        """
        bwa-mem2 mem \
        -t {threads} \
        {input.index} \
        {input.reads} \
        > {output} \
        2> {log}
        """