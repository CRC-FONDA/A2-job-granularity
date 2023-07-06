#!/usr/bin/bash -i

#must run interactive
if [[ ! $- == *i* ]]; then
    echo "script must be run in interactive mode"
    echo "Probably something like this:"
    echo bash -i $0 $@
    exit 1
fi

#weird stuff making sure that snakemake, python, tmux and bash work together
###################################################################################
. ~/.bashrc
export PATH="/data/scratch/manuez42/mambaforge/bin:$PATH"
export PATH="/data/scratch/manuez42/mambaforge/bin/:$PATH"
export PATH="/data/scratch/manuez42/mambaforge/envs/snakemake/lib/python3.11/site-packages/numpy:$PATH"
export PATH="/data/scratch/manuez42/mambaforge/envs/snakemake/lib/python3.11/site-packages/numpy/:$PATH"
export PATH="/data/scratch/mambaforge/envs/snakemake/lib/python3.11/isite-packages/pandas:$PATH"
export PATH="/data/scratch/manuez42/mambaforge/envs/snakemake/lib/python3.11/site-packages/pandas/:$PATH"
export PATH="/data/scratch/manuez42/tools/raptor/build/bin/:$PATH"
export PATH="/data/scratch/manuez42/tools/query-distributor/target/release:$PATH"

conda activate
source ~/.bashrc
conda activate snakemake
###################################################################################


### Variables to use###
###################################################################################
files0='/data/scratch/manuez42/genomes/viral_500M/files/'
files1='/data/scratch/manuez42/genomes/archaea_1,4G/files/'
files2='/data/scratch/manuez42/genomes/human_9G/files/'
files3='/data/scratch/manuez42/genomes/bacteria_30G/files/'
files4='/data/scratch/manuez42/genomes/bacteria_58G/files/'
files5='/data/scratch/manuez42/genomes/bacteria_88G/files/'
files6='/data/scratch/manuez42/genomes/bacteria_125G/files/'

steps0=(200 400 600 800 1000 1200 2400 3600 4800 6000 7200 8400 9600 10800 12000)
steps1=(25 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500)
steps2=(1 2 3)

#for every bacteria
steps3=(25 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500 550 600 650 700)


name_list=('viral_500M' 'archaea_1,4G' 'human_9G' 'bacteria_30G' 'bacteria_58G' 'bacteria_88G' 'bacteria_125G')
file_list=("$files0" "$files1" "$files2" "$files3" "$files4" "$files5" "$files6")
count_list=(11664 488 3 7167 15018 22185 31719)
size_list=(0.5 1.4 9.0 30.0 58.0 88.0 125.0)
step_list=("$steps0" "$steps1" "$steps2" "$steps3" "$steps3" "$steps3" "$steps3" )


timedefault=1800

path_to_collect='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/collect/'
path_to_final='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/final/'
home='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/'
###################################################################################


# functions to use
###################################################################################
randomX(){
    random_number=$((1 + RANDOM % $1))
    return $random_number
}

run_and_collect(){

    #make sure to be in the right place
    cd $home

    #remove leftovers
    rm -rf .snakemake
    rm -rf data/indicies
    rm -rf data/mapped_reads
    rm -rf data/genome_bins
    rm -rf data/distributed_reads
    rm -rf data/bins.tsv
    rm -rf data/prefilter
    rm -rf collect
    rm -rf slurm*
    rm -rf bwa-mem2-index*
    rm -rf node*.csv

    #create bins.tsv for new run
    ## $1 is filepath
    ## $2 is files per bin
    python create_simple_bin_file.py $1 $2
    mv bins.tsv data/

    #new run
    ## $3 is time for the workflow to run in seconds
    snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120  --nodelist={resources.nodelist} --mem=$3 --partition="big"' -j 1000 --latency-wait 6000 &
    command_pid=$!        # Get the process ID (PID) of the command

    sleep $4
    kill $command_pid
   

    #collect the data
    ## $4 is the name of the data
    mkdir -p collect
    ls -lsh data/genome_bins/ | awk '{print$6, "\t", $10 }' > datasizes.tsv

    mv slurm* $path_to_collect
    mv bwa-mem2-index* $path_to_collect
    mv node*.csv $path_to_collect
    mv datasizes.tsv $path_to_collect
    
    python Scripts/building_result.py $path_to_collect $5
   
    mv result* final/

    echo "$5 done" 
}

runrunrun(){
    local my_list=("$1")
    local name="$2"
    local time="$3"
    local 

    for item in "${my_list[@]}"; do
    
    done
}
###################################################################################




cd $home
mkdir -p final

for ((i=0; i<100; i++)); do
    echo "Iteration $i"

    for ((j=0; i<7; j++)); do
    echo "Iteration $i$j"

        for ((k=0; i<10; k++)); do
        echo "Iteration $i$j$k"
            run_and_collect 
        done

    done

done

### archaea ###
run_and_collect $files1 200 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 200 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 100 $path_to_collect 1.4 $name12 3000
run_and_collect $files1 75 $path_to_collect 1.4 $name13 3000
run_and_collect $files1 50 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 45 $path_to_collect 1.4 $name13 3000
run_and_collect $files1 40 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 35 $path_to_collect 1.4 $name12 3000
run_and_collect $files1 30 $path_to_collect 1.4 $name13 3000
run_and_collect $files1 25 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 20 $path_to_collect 1.4 $name13 3000
run_and_collect $files1 15 $path_to_collect 1.4 $name11 3000
run_and_collect $files1 10 $path_to_collect 1.4 $name13 3000
run_and_collect $files1 5 $path_to_collect 1.4 $name13 3000


# ### bacteria ###
run_and_collect $files2 750 $path_to_collect 125 $name2 5000
run_and_collect $files2 675 $path_to_collect 125 $name22 5000
run_and_collect $files2 600 $path_to_collect 125 $name23 5000
run_and_collect $files2 525 $path_to_collect 125 $name2 5000
run_and_collect $files2 450 $path_to_collect 125 $name22 5000
run_and_collect $files2 375 $path_to_collect 125 $name22 5000
run_and_collect $files2 300 $path_to_collect 125 $name23 5000
run_and_collect $files2 225 $path_to_collect 125 $name23 5000
run_and_collect $files2 150 $path_to_collect 125 $name2 5000
run_and_collect $files2 100 $path_to_collect 125 $name22 5000
run_and_collect $files2 75 $path_to_collect 125 $name22 5000
run_and_collect $files2 50 $path_to_collect 125 $name23 5000

run_and_collect $files3 700 $path_to_collect 30 $name3 3000
run_and_collect $files3 600 $path_to_collect 30 $name3 3000
run_and_collect $files3 500 $path_to_collect 30 $name3 3000
run_and_collect $files3 400 $path_to_collect 30 $name3 3000
run_and_collect $files3 300 $path_to_collect 30 $name3 3000
run_and_collect $files3 200 $path_to_collect 30 $name3 3000
run_and_collect $files3 100 $path_to_collect 30 $name3 3000
run_and_collect $files3 350 $path_to_collect 30 $name3 3000
run_and_collect $files3 250 $path_to_collect 30 $name3 3000
run_and_collect $files3 150 $path_to_collect 30 $name3 3000
run_and_collect $files3 50 $path_to_collect 30 $name3 3000
run_and_collect $files3 75 $path_to_collect 30 $name3 3000


run_and_collect $files4 750 $path_to_collect 58 $name4 4000
run_and_collect $files4 675 $path_to_collect 58 $bacteria58 4000
run_and_collect $files4 600 $path_to_collect 58 $name43 4000
run_and_collect $files4 525 $path_to_collect 58 $name4 4000
run_and_collect $files4 450 $path_to_collect 58 $bacteria58 4000
run_and_collect $files4 375 $path_to_collect 58 $name43 4000
run_and_collect $files4 300 $path_to_collect 58 $name4 4000
run_and_collect $files4 225 $path_to_collect 58 $bacteria58 4000
run_and_collect $files4 150 $path_to_collect 58 $name43 4000
run_and_collect $files4 100 $path_to_collect 58 $name4 4000
run_and_collect $files4 75 $path_to_collect 58 $bacteria58 4000
run_and_collect $files4 50 $path_to_collect 58 $name43 4000


run_and_collect $files5 750 $path_to_collect 88 $name51 5000
run_and_collect $files5 675 $path_to_collect 88 $name52 5000
run_and_collect $files5 600 $path_to_collect 88 $name53 5000
run_and_collect $files5 525 $path_to_collect 88 $name51 5000
run_and_collect $files5 450 $path_to_collect 88 $name52 5000
run_and_collect $files5 375 $path_to_collect 88 $name53 5000
run_and_collect $files5 300 $path_to_collect 88 $name51 5000
run_and_collect $files5 225 $path_to_collect 88 $name52 5000
run_and_collect $files5 150 $path_to_collect 88 $name53 5000
run_and_collect $files5 100 $path_to_collect 88 $name51 5000
run_and_collect $files5 75 $path_to_collect 88 $name52 5000
run_and_collect $files5 50 $path_to_collect 88 $name53 5000

# ### humans ###
run_and_collect $files6 3 $path_to_collect 9 $name61 5000
run_and_collect $files6 2 $path_to_collect 9 $name62 5000
run_and_collect $files6 1 $path_to_collect 9 $name63 5000

# ### viral ###
run_and_collect $files7 1200 $path_to_collect 0.5 $name71 5000
run_and_collect $files7 1100 $path_to_collect 0.5 $name72 5000
run_and_collect $files7 1000 $path_to_collect 0.5 $name73 5000
run_and_collect $files7 900 $path_to_collect 0.5 $name71 5000
run_and_collect $files7 800 $path_to_collect 0.5 $name72 5000
run_and_collect $files7 700 $path_to_collect 0.5 $name73 5000
run_and_collect $files7 600 $path_to_collect 0.5 $name71 5000
run_and_collect $files7 500 $path_to_collect 0.5 $name72 5000
run_and_collect $files7 400 $path_to_collect 0.5 $name73 5000
run_and_collect $files7 300 $path_to_collect 0.5 $name71 5000
run_and_collect $files7 200 $path_to_collect 0.5 $name72 5000
run_and_collect $files7 1000 $path_to_collect 0.5 $name73 5000

