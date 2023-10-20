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
files2='/data/scratch/manuez42/genomes/bacteria_011G/files/'
files3='/data/scratch/manuez42/genomes/bacteria_030G/files/'
files4='/data/scratch/manuez42/genomes/bacteria_058G/files/'
files5='/data/scratch/manuez42/genomes/bacteria_088G/files/'
files6='/data/scratch/manuez42/genomes/bacteria_125G/files/'

#viral
steps0=(200 400 600 800 1000 1200 2400 3600 4800 6000 7200 8400 9600 10800 12000)
#archaea
steps1=(25 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500)

#for every bacteria
steps2=(25 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500 550 600 650 700)


name_list=('viral_500M' 'archaea_1,4G' 'bacteria_011G' 'bacteria_030G' 'bacteria_058G' 'bacteria_088G' 'bacteria_125G')
file_list=("$files0" "$files1" "$files2" "$files3" "$files4" "$files5" "$files6")
count_list=(11664 488 2541 7167 15018 22185 31719)
size_list=(0.5 1.4 11.0 30.0 58.0 88.0 125.0)
step_list=("$steps0" "$steps1" "$steps2" "$steps2" "$steps2" "$steps2" "$steps2" )
time_list=(1800 1800 2400 3000 3600 4200 4800)


path_to_collect='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/collect/'
path_to_final='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/final/'
home='/data/scratch/manuez42/A2-job-granularity/MG-HIBF/'
###################################################################################


# functions to use
###################################################################################
# $1 is range (-$1,$1)
# $2 is the default number to mix up
# is used for steps and for time
randomX(){
    random_number=$((RANDOM % (2 * $1 + 1) - $1))
    result=$(($2 + random_number))
    return $result
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
    ## $3 is memory
    snakemake --use-conda -s Snakefile --cluster "sbatch -t 120  --nodelist={resources.nodelist} --mem=$3 --partition='big'" -j 1000 --latency-wait 6000 &
    command_pid=$!        # Get the process ID (PID) of the command

    ## $4 is time for the workflow to run in seconds
    sleep $4
    kill $command_pid
   

    #collect the data
    ## $5 is the name of the data
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
###################################################################################



cd $home
mkdir -p final

for ((i=0; i<100; i++)); do
    echo "Iteration $i"

    for ((j=0; i<7; j++)); do
    echo "Iteration $i$j"

        j_name="${name_list[j]}"
        j_file="${file_list[j]}"
        j_file_count="${count_list[j]}"
        j_size="${size_list[j]}"
        j_step_list="${step_list[j]}"
        j_time="${time_list[j]}"

        for ((k=0; i<10; k++)); do
            echo "Iteration $i$j$k"

            list_length=${#j_step_list[@]}
            random_index=$((RANDOM % list_length))
            r_step="${j_step_list[random_index]}"

            k_steps=$(randomX "$(($r_step / 10))" "$r_step")
            k_time=$(randomX "$(($j_time / 6))" "$j_time")
            k_size=$(randomX "$j_size" "$(($j_size * 3))")
    ## $1 is filepath
    ## $2 is files per bin
    ## $3 is memory
    ## $4 is time
    ## $5 is the name

            run_and_collect $j_file $k_steps $k_size $k_time $j_name

        done

    done

done


