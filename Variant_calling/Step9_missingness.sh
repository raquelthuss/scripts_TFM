#!/bin/bash
#SBATCH --job-name=miss_filt_chr
#SBATCH --output=03_missingness_%A_%a.log
#SBATCH --error=03_missingness_%A_%a.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --array=1-20
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=raqthu@alum.us.es

set -euo pipefail

module load BCFtools/1.18-GCC-12.3.0 || true
module load HTSlib/1.18-GCC-12.3.0   || true

# =========================
# EDIT ONLY THIS
# =========================
INDIR="../joint_genotype/gatk_filtered_biallelic_maskGT_dp5"
OUTDIR="../joint_genotype/gatk_filtered_biallelic_maskGT_miss20"

MAX_MISSING=0.20   # 0.10 looser; 0.05 standard for GWAS-ready
THREADS="${SLURM_CPUS_PER_TASK:-1}"
# =========================

mkdir -p "$OUTDIR"

CHR=$(printf "Gs%02d" "$SLURM_ARRAY_TASK_ID")

IN_VCF="${INDIR}/${CHR}_GATK_snps_PASS_biallelic_maskGT.vcf.gz"
# OUT_VCF="${OUTDIR}/${CHR}_GATK_snps_PASS_biallelic_maskGT_miss$(printf "%03d" $(echo "$MAX_MISSING*1000" | bc -l | cut -d. -f1)).vcf.gz"
# The OUT_VCF line above makes a nice suffix like miss050 for 0.05; if you prefer miss005, set it manually below.

# If you want EXACTLY "miss005" naming, comment the OUT_VCF line above and use this:
OUT_VCF="${OUTDIR}/${CHR}_GATK_snps_PASS_biallelic_maskGT_miss20.vcf.gz"

echo "============================================================"
echo "[INFO] Filter sites by missingness after masking — per chr"
echo "[INFO] Chr   : $CHR"
echo "[INFO] Keep  : F_MISSING < $MAX_MISSING"
echo "[INFO] Input : $IN_VCF"
echo "[INFO] Output: $OUT_VCF"
echo "[INFO] Threads: $THREADS"
echo "============================================================"
date

[[ -f "$IN_VCF" ]] || { echo "[ERROR] Missing input VCF: $IN_VCF"; exit 1; }

# Ensure index exists
if [[ ! -f "${IN_VCF}.tbi" && ! -f "${IN_VCF}.csi" ]]; then
  echo "[INFO] Index missing -> tabix indexing"
  tabix -p vcf "$IN_VCF"
fi

echo "=== COUNTS BEFORE ==="
echo "Samples : $(bcftools query -l "$IN_VCF" | wc -l)"
echo "Variants: $(bcftools index -n "$IN_VCF")"
echo "------------------------------------------------------------"

bcftools view --threads "$THREADS" -i "F_MISSING<${MAX_MISSING}" -Oz -o "$OUT_VCF" "$IN_VCF"
tabix -f -p vcf "$OUT_VCF"

echo "=== COUNTS AFTER ==="
echo "Samples : $(bcftools query -l "$OUT_VCF" | wc -l)"
echo "Variants: $(bcftools index -n "$OUT_VCF")"
echo "============================================================"
echo "[DONE] $OUT_VCF"
echo "============================================================"
