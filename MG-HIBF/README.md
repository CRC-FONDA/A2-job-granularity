# HIBF distributed Readmapping Workflow

## Usage (Simple readmapping):

- Run the setup_tools.sh to install tools not available via conda (new gcc and cargo needed)
- Place a file that defines the reference genome files with bin ids into `data/bins.tsv`. For example:
- in bins.tsv, num of bins == num of nodes

## GCC
https://gcc.gnu.org/install/
for gcc it's more complicate

## Cargo
https://www.rust-lang.org/tools/install
for Rust you can just invoke 

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


```
x.fna	0   cmp201
y.fna	0   cmp201
z.fna	1   cmp247
w.fna	1   cmp247
v.fna	2   cmp230
```
- The script `create_simple_bin_file.py` can help in creating the bin file. Example usage:

```
python create_simple_bin_file.py /data/username/genomes/ <NUM_FILES_PER_BIN>
```

- Then, place the query reads in the file data/queries.fastq

- use with snakemake flag --use-conda
