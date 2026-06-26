#!/bin/bash
#SBATCH --job-name=vcf_setIDs
#SBATCH --output=00_assign_snp_names_%A_%a.log
#SBATCH --error=00_assign_snp_names_%A_%a.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=12G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=cjacott@us.es
#SBATCH --array=0-20

set -euo pipefail

module purge 2>/dev/null || true
module load BCFtools/1.18-GCC-12.3.0
module load HTSlib/1.18-GCC-12.3.0

# =========================
# EDIT ONLY THIS
# =========================
INDIR="../joint_genotype"
OUTDIR="../joint_genotype/vcf_with_SNP_IDs"
PATTERN="Gs*_genotyped_chunks.vcf.gz"
IDFMT='%CHROM:%POS:%REF-%ALT'
# =========================

mkdir -p "$OUTDIR"

shopt -s nullglob
FILES=( "$INDIR"/$PATTERN )
shopt -u nullglob

NFILES=${#FILES[@]}
if [[ $NFILES -eq 0 ]]; then
  echo "[ERROR] No files found: $INDIR/$PATTERN"
  exit 1
fi

TASK_ID=${SLURM_ARRAY_TASK_ID}
if [[ $TASK_ID -ge $NFILES ]]; then
  echo "[INFO] Task $TASK_ID exceeds file count ($NFILES). Exiting."
  exit 0
fi

VCF_IN="${FILES[$TASK_ID]}"
base=$(basename "$VCF_IN")
VCF_OUT="$OUTDIR/${base/_chunks.vcf.gz/_chunks_ID.vcf.gz}"

echo "============================================================"
echo "[INFO] SLURM job     : $SLURM_JOB_ID"
echo "[INFO] Array task    : $TASK_ID"
echo "[INFO] Input file    : $VCF_IN"
echo "[INFO] Output file   : $VCF_OUT"
echo "============================================================"
date

# Ensure index exists
if [[ ! -f "${VCF_IN}.tbi" && ! -f "${VCF_IN}.csi" ]]; then
  echo "[INFO] Input index missing -> tabix indexing"
  tabix -p vcf "$VCF_IN"
fi

# Set SNP IDs
bcftools annotate --set-id "$IDFMT" -Oz -o "$VCF_OUT" "$VCF_IN"
tabix -f -p vcf "$VCF_OUT"

# Sanity checks
echo "[INFO] First 3 records:"
bcftools view -H "$VCF_OUT" | head -n 3 | cut -f1-5
echo "[INFO] Missing IDs remaining:"
bcftools query -f '%ID\n' "$VCF_OUT" | awk '$1=="."{c++} END{print c+0}'

echo "============================================================"
echo "[DONE] Task $TASK_ID finished."
date
