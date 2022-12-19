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
- The script `create_simple_bin_file.py` can help in creating the bin file. Example usage:

```
python create_simple_bin_file.py /data/username/genomes/ <NUM_FILES_PER_BIN>
```

- Then, place the query reads in the file data/queries.fastq

- use with snakemake flag --use-conda
