# Optimizing job granularity of metagenomic workflows metagenomic workflows where the number of jobs for the read mapping step can be customized by the user. 

This repository contains various metagenomic workflows where the number of jobs for the read mapping step can be customized by the user. 

The repository is divided into subprojects, details of each below.

---

## Running snakemake

To run the snakemake workflow in one of the subfolders:
`snakemake --use-conda --cores {e.g 8}`

Other useful flags:
1. `--force-use-threads` add this flag to force threads instead of processes in case each process takes too much local memory to be run in parallel 
2. `snakemake --dag | dot -Tpng > dag.png` don't run any jobs just create a figure of the directed acyclic graph
3. `snakemake --dryrun` don't run any jobs just display the order in which they would be executed.

---

## Simulated data

### raptor_data_simulation
Simulating DNA sequences with https://github.com/eseiler/raptor_data_simulation.
Run this workflow before running any of the MG-* workflows. The data simulation parameters are set in `simulation_config.yaml`. All MG-x workflows have a separate configuration file called `search_config.yaml` where prefiltering and search parameters should be set. 

**NOTE:** Raptor data simulation has to be built from source. 

Data simulation source code:
https://github.com/eseiler/raptor_data_simulation


### MG-4
![directed acyclic graph for MG-4](https://github.com/eaasna/A2-job-granularity/blob/main/MG-4/dag.png)

This workflow uses the same tools as MG-1 and MG-3 in https://github.com/eaasna/A2-metagenome-snakemake. The IBF prefiltering uses a lot of main memory compared to the prefiltering method in MG-5.

Steps of workflow:
1. Create an IBF over the simulated reference data (one job)
2. Create an FM-index for each of the bins of the reference (one job per bin)
3. Map each read to the FM-index determined by IBF pre-filtering (number of jobs can be chosen by user in `simulation_config.yaml`) 

**NOTE:** DREAM-Yara is not available through conda and has to be built from source. Also add location of DREAM-Yara binaries to $PATH.

DREAM-Yara source code:
https://github.com/temehi/dream_yara

The example graph above shows a workflow run where:
- number of bins = 8
- number of read files = 4

which means there are 8 jobs for the FM-index building step and 4 jobs for the mapping step. 

**NOTE:** that the total number of reads has to be divisible by the chosen number of read files.  

### MG-5
![directed acyclic graph for MG-5](https://github.com/eaasna/A2-job-granularity/blob/main/MG-5/dag.png)

This workflow uses the same tools as MG-2 in  https://github.com/eaasna/A2-metagenome-snakemake. This version aims to work around the constraint of having low memory by using a hash table based approach instead of the IBF. The user can customise the number of jobs. 

Steps of workflow:
1. Create a hash table over the simulated reference data (1 thread; 1 job)
2. Query the reads in the hashmap and determine potential bin matches (multithreaded; number of jobs can be chosen by user in `simulation_config.yaml`)
3. Distribute reads by writing e.g all reads that should be mapped to bin 1 to a file (1 thread; 1 job)
4. Create an FM-index for each of the bins of the reference (multithreaded; 1 job per bin)
5. Read the distributed reads and map to the FM-index determined by hashmap pre-filtering (1 job per bin)
6. If a read was mapped to multiple bins the strata mapping results have to be consolidated between bins. For match consolidation the mapping results are gathered into one file and filtered based on the best+x cutoff set by the user in the configuration file. (1 thread; 1 job)

**NOTE:** The hashmap and match-consolidator have to be built from source and the location of the binaries should be added to $PATH.

Hashmap source code: 
https://github.com/eaasna/low-memory-prefilter

Match consolidator source code:
https://github.com/eaasna/match-consolidator