#!/usr/bin/bash

### Path to files ###
files1='/buffer/ag_abi/manuel/fonda/genomes/archaea_1,4G/files/'
files2='/buffer/ag_abi/manuel/fonda/genomes/bacteria_125G/files/'
files3='/buffer/ag_abi/manuel/fonda/genomes/bacteria_30G/files/'
files4='/buffer/ag_abi/manuel/fonda/genomes/bacteria_58G/files/'
files5='/buffer/ag_abi/manuel/fonda/genomes/bacteria_88G/files/'
files6='/buffer/ag_abi/manuel/fonda/genomes/human_9G/files/'
files7='/buffer/ag_abi/manuel/fonda/genomes/viral_500M/files/'

path_to_collect='~/fonda/A2-job-granularity/MG-HIBF/collect/'

### running
function run(){
    python create_simple_bin_file.py $1 $2
    mv bins.tsv data/bins.tsv
    snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120 --nodelist={resources.nodelist}' -j 100 --latency-wait 600
}

##collecting
function collecting (){
    mkdir collect
    mv slurm* collect/
    mv bwa-mem2-index* collect/
    mv nodes.csv collect/
    python Scripts/building_result.py $path_to_collect $1
    rm -r collect
}

cd ..
mkdir results

### humans ###
run $files6 3
collecting 9
mv test.csv results/9G_bin_0.csv



