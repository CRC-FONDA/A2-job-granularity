#!/usr/bin/bash

### Path to files ###
file1='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
file2='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
file3='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
file4='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'
file5='/data/scratch/SomayehM/genomes/archaea_complete_genomes/2022-12-06_21-03-30/files'

sinfo --long --Node | grep "small" | grep "mixed" >> nodelist.csv

create_bin='python create_simple_bin_file.py'
### + /data/username/genomes/ <NUM_FILES_PER_BIN>

move_bin='mv bins.tsv data/bins.tsv'

### running
### conda activate snakemake
### snakemake --use-conda -s Snakefile --cluster 'sbatch -t 120 --nodelist={resources.nodelist}  --mem=3g' -j 100 --latency-wait 80

mkdir collect
move_log='mv slurm-* collect/'
cp_log='cp <bwa mem log> collect/'
collecting='python collect/'

rm -r collect/