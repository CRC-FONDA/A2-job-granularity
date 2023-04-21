#!/usr/bin/bash
export PATH="~/miniconda3/bin:$PATH"
export PATH="/home/manuez42/miniconda3/bin:$PATH"
export PATH="/home/manuez42/miniconda3/envs/snakemake/lib/python3.11/site-packages/:$PATH"

### Path to files ###
name1='archaea_1,4G'
files1='/data/scratch/manuez42/genomes/archaea_1,4G/files/'

name2='bacteria_125G'
files2='/data/scratch/manuez42/genomes/bacteria_125G/files/'

name3='bacteria_30G'
files3='/data/scratch/manuez42/genomes/bacteria_30G/files/'

name4='bacteria_58G'
files4='/data/scratch/manuez42/genomes/bacteria_58G/files/'

name5='bacteria_88G'
files5='/data/scratch/manuez42/genomes/bacteria_88G/files/'

name6='human_9G'
files6='/data/scratch/manuez42/genomes/human_9G/files/'

name7='viral_500M'
files7='/data/scratch/manuez42/genomes/viral_500M/files/'

path_to_collect='~/fonda/A2-job-granularity/MG-HIBF/collect/'

run_and_collect(){
    ## $1 is filepath
    ## $2 is files per bin
    python create_simple_bin_file.py $1 $2
    mv bins.tsv data/
    snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120 --nodelist={resources.nodelist}' -j 100 --latency-wait 600
    
    ## $3 path to collect
    ## $4 DataSize in GB 
    ## $5 is Name
    mkdir collect

    mv slurm* collect/
    mv bwa-mem2-index* collect/
    mv node*.csv collect/

    python Scripts/building_result.py $3 $4 $5
    mv result*.csv final/
    
    rm -r data/indicies
    rm -r data/mapped_reads
    rm -r data/genome_bins
    rm -r data/distributed_reads
    rm -r data/bins.tsv
    rm -r data/prefilter
    rm -r collect
    rm -r data/nodelist.csv

}

### conda activate snakemake must be activated before ###
cd ..
mkdir final
conda activate

source ~/.bashrc

conda activate snakemake

### archaea ###
run_and_collect $files1 200 $path_to_collect 1.4 $name1
# run_and_collect $files1 40 $path_to_collect 1.4 $name1
# run_and_collect $files1 130 $path_to_collect 1.4 $name1

# ### bacteria ###
# run_and_collect $files2 500 $path_to_collect 125 $name2
# run_and_collect $files2 80 $path_to_collect 125 $name2
# run_and_collect $files2 300 $path_to_collect 125 $name2

# run_and_collect $files3 80 $path_to_collect 30 $name3
# run_and_collect $files3 30 $path_to_collect 30 $name3
# run_and_collect $files3 150 $path_to_collect 30 $name3

# run_and_collect $files4 50 $path_to_collect 58 $name4
# run_and_collect $files4 100 $path_to_collect 58 $name4
# run_and_collect $files4 200 $path_to_collect 58 $name4

# run_and_collect $files5 50 $path_to_collect 88 $name5
# run_and_collect $files5 200 $path_to_collect 88 $name5
# run_and_collect $files5 400 $path_to_collect 88 $name5

# ### humans ###
# run_and_collect $files6 3 $path_to_collect 9 $name6
# run_and_collect $files6 2 $path_to_collect 9 $name6
# run_and_collect $files6 1 $path_to_collect 9 $name6

# ### viral ###
# #run_and_collect $files7 100 $path_to_collect 0.5 $name7
# #run_and_collect $files7 300 $path_to_collect 0.5 $name7
# #run_and_collect $files7 500 $path_to_collect 0.5 $name7