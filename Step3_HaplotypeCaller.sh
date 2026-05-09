#!/bin/bash
#SBATCH --job-name=gatk_haplotype
#SBATCH --output=gatk_haplotype_%A_%a.log
#SBATCH --error=gatk_haplotype_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=96:00:00
#SBATCH --array=1-20   # 20 chromosomes

# ====== PATHS YOU CAN EDIT ======
BAM_DIR="../bwa_batch_5"
GVCF_DIR="../gvcf_batch_5"
REFERENCE="../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna"
# ================================

module load GATK/4.5.0.0-GCCcore-12.3.0-Java-17
module load BCFtools/1.18-GCC-12.3.0

# 20 chromosomes — clean, fixed, consistent
declare -a regions=(
"glyso.PI483463.gnm1.Gs01:1-57896170"
"glyso.PI483463.gnm1.Gs02:1-51286261"
"glyso.PI483463.gnm1.Gs03:1-47409649"
"glyso.PI483463.gnm1.Gs04:1-52689084"
"glyso.PI483463.gnm1.Gs05:1-42078728"
"glyso.PI483463.gnm1.Gs06:1-50872493"
"glyso.PI483463.gnm1.Gs07:1-44817240"
"glyso.PI483463.gnm1.Gs08:1-48336061"
"glyso.PI483463.gnm1.Gs09:1-47987378"
"glyso.PI483463.gnm1.Gs10:1-52602533"
"glyso.PI483463.gnm1.Gs11:1-39224231"
"glyso.PI483463.gnm1.Gs12:1-41643695"
"glyso.PI483463.gnm1.Gs13:1-45697263"
"glyso.PI483463.gnm1.Gs14:1-50420661"
"glyso.PI483463.gnm1.Gs15:1-52554235"
"glyso.PI483463.gnm1.Gs16:1-37987242"
"glyso.PI483463.gnm1.Gs17:1-42245200"
"glyso.PI483463.gnm1.Gs18:1-57540831"
"glyso.PI483463.gnm1.Gs19:1-50221251"
"glyso.PI483463.gnm1.Gs20:1-48820172"
)

# Region for this array task
REGION="${regions[$((SLURM_ARRAY_TASK_ID-1))]}"

# Ensure BAMs exist
if ! ls "$BAM_DIR"/*_sorted_dedup*.bam 1>/dev/null 2>&1; then
    echo "No BAMs matching *_sorted_dedup*.bam found in $BAM_DIR"
    exit 1
fi

# Loop over BAMs
for bam in "$BAM_DIR"/*_sorted_dedup*.bam; do
    sample=$(basename "$bam" | sed 's/_sorted_dedup.*\.bam//')

    echo "[$(date)] Sample: $sample | Region: $REGION"

    OUT="$GVCF_DIR/${sample}_${REGION}.g.vcf.gz"

    gatk --java-options "-Xmx24g" HaplotypeCaller \
        -R "$REFERENCE" \
        -I "$bam" \
        -O "$OUT" \
        --emit-ref-confidence GVCF \
        --native-pair-hmm-threads 8 \
        --intervals "$REGION"

    echo "[$(date)] Finished $sample for $REGION → $OUT"
done
