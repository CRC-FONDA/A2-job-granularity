
# buidling bins --> bin_id, filename
# building nodelist --> bin_id, nodename
rule building_bins:
    input:
        folder_name
        files_per_bin
    output:
        "data/genome_bins/bins.tsv"
    shell:
        "python create_simple_bin_file.py folder_name files_per_bin"


rule buidling_nodes:
    input:
        "data/genome_bins/bins.tsv"
    output:
        "data/genome_bins/nodes.csv"
    shell:
        "bash sinfo --long --Node | grep -P mix | grep -P big | awk '{print $1}' > nodes.csv"


rule making_variables:
    input:
        "data/genome_bins/bins.tsv"
    output:
        bin_ids
        genome_bin_files = expand("data/genome_bins/bin_{bin_id}.fasta", bin_id=bin_ids)
        distributed_read_files = expand("data/distributed_reads/bin_{bin_id}.fastq", bin_id=bin_ids)
    run:
        num_bins = 0
        bins = defaultdict(lambda: [])

        with open("data/bins.tsv", "r") as f:
            reader = csv.reader(f, delimiter='\t')
            
            for row in reader:
                filename = row[0]
                bin_id = int(row[1])
                bins[bin_id].append(filename)
                num_bins = max(num_bins, bin_id + 1)

        if list(range(num_bins)) != list(bins.keys()):
            raise RuntimeError("Error bins.tsv")

        bin_ids = range(num_bins)
            


rule building_nodelist:
    input: 
        bin_ids
        "data/genome_bins/nodes.csv"
    output:
        "data/genom_bins/nodelist.csv"
    run:
        list_of_nodes = []
        nodes = {}

        with open("data/genome_bins/nodes.csv", "r") as f:
            reader = csv.reader(f, delimiter=',')
            for row in reader:
                list_of_nodes.append(row[0])

        for i in bin_ids:
            nodes[i] = random.choice(list_of_nodes)

        with open("data/genome_bins/nodelist.csv", "w+") as f:
            writer = csv.writer(f, delimiter=',')
            for b, node in nodes.items():
                writer.writerow( [b, node] )


