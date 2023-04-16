### Path to files ###
files1='/buffer/ag_abi/manuel/fonda/genomes/archaea_1,4G/'
files2='/buffer/ag_abi/manuel/fonda/genomes/bacteria_125G/'
files3='/buffer/ag_abi/manuel/fonda/genomes/bacteria_30G/'
files4='/buffer/ag_abi/manuel/fonda/genomes/bacteria_58G/'
files5='/buffer/ag_abi/manuel/fonda/genomes/bacteria_88G/'
files6='/buffer/ag_abi/manuel/fonda/genomes/human_9G/'
files7='/buffer/ag_abi/manuel/fonda/genomes/viral_500M/'

path_to_collect='~/fonda/A2-job-granularity/MG-HIBF/collect/'

### running
run(){
    python create_simple_bin_file.py $1 $2
    mv bins.tsv data/bins.tsv
    snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120 --nodelist={resources.nodelist}' -j 100 --latency-wait 600
}

##collecting
collecting (){
    mkdir collect
    mv slurm* collect/
    mv bwa-mem2-index* collect/
    mv data/bins.tsv collect/
    mv nodes.csv collect/
    python Scripts/building_result $path_to_collect $1
    rm -r collect
}

cd ..
conda activate snakemake

### humans ###
run $files6 3
collecting '9G'

