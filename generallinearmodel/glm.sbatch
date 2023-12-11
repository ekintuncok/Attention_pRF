#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --time=5:00:00
#SBATCH --mem=150GB
#SBATCH --job-name=myTest
#SBATCH --mail-type=END
#SBATCH --mail-user=et2160@nyu.edu
#SBATCH --output=ish_%j.out
  
module purge
module load matlab/2022b

matlab -nodisplay -nodesktop -r "run_GLM('wlsubj138')"

