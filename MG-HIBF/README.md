# HIBF distributed Readmapping Workflow

## Usage (Simple readmapping):

- Place all .fasta files of the reference genomes in the data/genomes folder
- Place the query reads in the file data/queries.fastq
- run the setup.sh to install tools not available via conda (new gcc and cargo needed)
- use with snakemake flag --use-conda

## TODOs

- support possibly multiple fastq query files (allows to distribute prefilter work)
- figure out all the stuff about the cluster execution
