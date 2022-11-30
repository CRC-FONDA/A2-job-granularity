# HIBF distributed Readmapping Workflow

## Usage (Simple readmapping):

- Place all .fasta files of the reference genomes in the data/genomes folder
- Place the query reads in the file data/queries.fastq
- run the setup.sh to install tools not available via conda (new gcc and cargo needed)
- assume the existence of a file `data/genomes/bins.tsv` that groups all read files into bins, like this:

```
x.fna	0
y.fna	0
z.fna	1
w.fna	1
v.fna	2
```

- use with snakemake flag --use-conda

## TODOs

- find input data (4,20,200 GB) + reads
- make nicer DAG image
    - subworkflow, virtual binning, less bins
- figure out all the stuff about the cluster execution
