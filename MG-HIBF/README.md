# HIBF distributed Readmapping Workflow

## Usage (Simple readmapping):

- Run the setup.sh to install tools not available via conda (new gcc and cargo needed)
- Place a file that defines the reference genome files with bin ids into `data/bins.tsv`. For example:

```
x.fna	0
y.fna	0
z.fna	1
w.fna	1
v.fna	2
```

- Place the query reads in the file data/queries.fastq

- use with snakemake flag --use-conda
