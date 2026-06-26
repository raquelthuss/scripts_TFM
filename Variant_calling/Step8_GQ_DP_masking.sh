#!/bin/bash
#SBATCH --job-name=maskGT_chr
#SBATCH --output=02_maskGT_chr_%A_%a.log
#SBATCH --error=02_maskGT_chr_%A_%a.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --array=1-20
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=raqthu@alum.us.es

set -euo pipefail

module load BCFtools/1.18-GCC-12.3.0 || true
module load HTSlib/1.18-GCC-12.3.0   || true

# =========================
# EDIT ONLY THIS
# =========================
INDIR="../joint_genotype/gatk_snps_filtered_biallelic"
OUTDIR="../joint_genotype/gatk_filtered_biallelic_maskGT_dp5"

MIN_DP=5
MAX_DP=0      # set to 0 to disable
MIN_GQ=20      # set to 0 if FORMAT/GQ not present

THREADS="${SLURM_CPUS_PER_TASK:-1}"
# =========================

mkdir -p "$OUTDIR"

CHR=$(printf "Gs%02d" "$SLURM_ARRAY_TASK_ID")

IN_VCF="${INDIR}/${CHR}_GATK_snps_PASS_biallelic.vcf.gz"
OUT_VCF="${OUTDIR}/${CHR}_GATK_snps_PASS_biallelic_maskGT.vcf.gz"

echo "============================================================"
echo "[INFO] Mask genotypes failing DP/GQ (set to ./.) — per chr"
echo "[INFO] Chr    : $CHR"
echo "[INFO] Input  : $IN_VCF"
echo "[INFO] Output : $OUT_VCF"
echo "[INFO] MIN_DP=$MIN_DP  MAX_DP=$MAX_DP  MIN_GQ=$MIN_GQ"
echo "[INFO] Threads: $THREADS"
echo "============================================================"
date

[[ -f "$IN_VCF" ]] || { echo "[ERROR] Missing input VCF: $IN_VCF"; exit 1; }

# Ensure index exists
if [[ ! -f "${IN_VCF}.tbi" && ! -f "${IN_VCF}.csi" ]]; then
  echo "[INFO] Index missing -> tabix indexing"
  tabix -p vcf "$IN_VCF"
fi

# If GQ missing, disable MIN_GQ automatically
HAS_GQ=$(bcftools view -h "$IN_VCF" | grep -c '##FORMAT=<ID=GQ,')
if [[ "$MIN_GQ" != "0" && "$HAS_GQ" -eq 0 ]]; then
  echo "[WARN] FORMAT/GQ not found in header, forcing MIN_GQ=0"
  MIN_GQ=0
fi

echo "=== COUNTS BEFORE ==="
echo "Samples : $(bcftools query -l "$IN_VCF" | wc -l)"
echo "Variants: $(bcftools index -n "$IN_VCF")"

# Build expression
expr="FMT/DP<${MIN_DP}"
if [[ "$MAX_DP" != "0" ]]; then expr="${expr} || FMT/DP>${MAX_DP}"; fi
if [[ "$MIN_GQ" != "0" ]]; then expr="${expr} || FMT/GQ<${MIN_GQ}"; fi
echo "Mask expression: $expr"
echo "------------------------------------------------------------"

# IMPORTANT: output options belong to bcftools main command, not plugin args
bcftools +setGT --threads "$THREADS" -Oz -o "$OUT_VCF" "$IN_VCF" -- \
  -t q -n . \
  -i "$expr"

tabix -f -p vcf "$OUT_VCF"

echo "=== COUNTS AFTER ==="
echo "Samples : $(bcftools query -l "$OUT_VCF" | wc -l)"
echo "Variants: $(bcftools index -n "$OUT_VCF")"
echo "[NOTE] Variant count unchanged; some genotypes are now missing."
echo "============================================================"
echo "[DONE] $OUT_VCF"
echo "============================================================"
