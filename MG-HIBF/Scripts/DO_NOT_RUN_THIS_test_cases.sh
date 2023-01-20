## Test_cases
#!/bin/bash

## Resources 
#SBATCH --job-name=TestJob
#SBATCH --output=TestJob.out
#SBATCH --time=120
#SBATCH --ntasks=1
#SBATCH --cpus-per-task={params.t}
#SBATCH --mem-per-cpu=3g                    || memper cpu or memper Node --mem=3g
#SBATCH --latency-wait 80
#SBATCH --nodelist={resources.nodelist}

## Job Steps
srun snakemake --use-conda -s Snakefile --cluster --conda-frontend=mamba