#!/usr/bin/bash -i

if [[ ! $- == *i* ]]; then
    echo "script must be run in interactive mode"
    echo "Probably something like this:"
    echo bash -i $0 $@
    exit 1
fi

export PATH="~/miniconda3/bin:$PATH"
export PATH="~/miniconda3/envs/snakemake/lib/python3.11/site-packages/numpy:$PATH"
export PATH="~/miniconda3/envs/snakemake/lib/python3.11/isite-packages/pandas:$PATH"


### Path to files ###
name1='archaea'
files1='/data/scratch/manuez42/genomes/archaea_1,4G/files/'

name2='bacteria'
files2='/data/scratch/manuez42/genomes/bacteria_125G/files/'

name3='bacteria'
files3='/data/scratch/manuez42/genomes/bacteria_30G/files/'

name4='bacteria'
files4='/data/scratch/manuez42/genomes/bacteria_58G/files/'

name5='bacteria'
files5='/data/scratch/manuez42/genomes/bacteria_88G/files/'

name6='human'
files6='/data/scratch/manuez42/genomes/human_9G/files/'

name7='viral'
files7='/data/scratch/manuez42/genomes/viral_500M/files/'

path_to_collect='collect/'

run_and_collect(){
    ## $1 is filepath
    ## $2 is files per bin
    python create_simple_bin_file.py $1 $2
    mv bins.tsv data/
    snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120 --nodelist={resources.nodelist} --partition="big"' -j 100 --latency-wait 600
    
    
    mkdir -p collect

    mv slurm* collect/
    mv bwa-mem2-index* collect/
    mv node*.csv collect/

    # $3 path to collect
    ## $4 DataSize in GB 
    ## $5 is Name
    python Scripts/building_result.py $3 $4 $5
    mv result*.csv final/
    
    rm -rf data/indicies
    rm -rf data/mapped_reads
    rm -rf data/genome_bins
    rm -rf data/distributed_reads
    rm -rf data/bins.tsv
    rm -rf data/prefilter
    rm -rf collect
    rm -rf data/nodelist.csv

}

### conda activate snakemake must be activated before ###
cd ..
mkdir -p final

conda activate

source ~/.bashrc

conda activate snakemake
### archaea ###
#run_and_collect $files1 200 $path_to_collect 1.4 $name1
#run_and_collect $files1 40 $path_to_collect 1.4 $name1
run_and_collect $files1 80 $path_to_collect 1.4 $name1

# ### bacteria ###
#run_and_collect $files2 500 $path_to_collect 125 $name2
#run_and_collect $files2 80 $path_to_collect 125 $name2
#run_and_collect $files2 300 $path_to_collect 125 $name2

run_and_collect $files3 80 $path_to_collect 30 $name3
run_and_collect $files3 120 $path_to_collect 30 $name3
run_and_collect $files3 150 $path_to_collect 30 $name3

run_and_collect $files4 80 $path_to_collect 58 $name4
run_and_collect $files4 90 $path_to_collect 58 $name4
run_and_collect $files4 100 $path_to_collect 58 $name4

#run_and_collect $files5 50 $path_to_collect 88 $name5
#run_and_collect $files5 200 $path_to_collect 88 $name5
#run_and_collect $files5 400 $path_to_collect 88 $name5

# ### humans ###
run_and_collect $files6 3 $path_to_collect 9 $name6
run_and_collect $files6 2 $path_to_collect 9 $name6
run_and_collect $files6 1 $path_to_collect 9 $name6

# ### viral ###
#run_and_collect $files7 100 $path_to_collect 0.5 $name7
#run_and_collect $files7 300 $path_to_collect 0.5 $name7
#run_and_collect $files7 500 $path_to_collect 0.5 $name7
