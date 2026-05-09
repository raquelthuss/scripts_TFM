#!/bin/bash
#SBATCH --job-name=bwa_index
#SBATCH --output=bwa_index.log
#SBATCH --error=bwa_index.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G
#SBATCH --time=02:00:00

start_time=$(date +%s)
echo "Start time: $(date)"

# -------------------
# Load modules
# -------------------

module purge
module load BWA/0.7.17-GCCcore-12.2.0
module load SAMtools/1.17-GCC-12.2.0
module load GATK/4.5.0.0-GCCcore-12.3.0-Java-17

# -------------------
# PATH
# -------------------

cd /home/rthuss/tfm/ref

# -------------------
# BWA-index
# -------------------

bwa index glyso.PI483463.gnm1.YJWS.genome_main.fna
# Generates an index for the alignment

samtools faidx glyso.PI483463.gnm1.YJWS.genome_main.fna
# Generates .fai that contains: chr | length | position | line length

gatk CreateSequenceDictionary -R glyso.PI483463.gnm1.YJWS.genome_main.fna
# Generates a dictionary for GATK (without sequences, only metadata)

# ------------------
# Done
# ------------------

echo "Bwa-index ready"

end_time=$(date +%s)
echo "End time: $(date)"
echo "Total runtime: $((end_time - start_time)) seconds"


