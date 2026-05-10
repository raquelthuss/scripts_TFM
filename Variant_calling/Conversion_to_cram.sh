#!/bin/bash
#SBATCH --job-name=bam_to_cram
#SBATCH --output=conversion_%j.log
#SBATCH --error=conversion_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --time=08:00:00

start_time=$(date +%s)
echo "Start time:$(date)"

# -------------------
# Load modules
# -------------------
module purge
module load SAMtools/1.17-GCC-12.2.0

# -------------------
# PATH
# -------------------

REF="../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna"
DATA_DIR="../bwa_batch_4"

echo "Processing files from: $DATA_DIR"
echo "Reference used: $REF"

# -------------------
# Conversion .bam to cram
# -------------------

cd $DATA_DIR

for BAM in *.bam; do
	[ -e "$BAM" ] || continue
	CRAM="${BAM%.bam}.cram"

	echo "----------------------------------------------"
	echo "Converting $BAM"

	samtools view -C -T "$REF" -o "$CRAM" "$BAM" --threads "$SLURM_CPUS_PER_TASK"

	if [ $? -eq 0 ]; then
		echo "Conversión exitosa: $CRAM"
		echo "Generando índice .crai..."
		samtools index "$CRAM"

		if [ -s "$CRAM" ]; then
			echo "Borrando .bam y índices antiguos"
			rm "$BAM"
			rm "${BAM}.bai" "${BAM%.bam}.bai" "${BAM}.sbi" "${BAM%.bam}.sbi" 2>/dev/null
		fi
	else
		echo "ERROR en conversión de $BAM. Se conservan los índices originales"
	fi
done

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "---------------------------------------------------"
echo "End time: $(date)"
echo "Elapsed time: $((elapsed / 60)) minutes and $((elapsed % 60)) seconds."
