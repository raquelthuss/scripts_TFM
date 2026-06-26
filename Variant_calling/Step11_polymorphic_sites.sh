#!/usr/bin/env bash
#SBATCH --job-name=poly_only
#SBATCH --output=poly_only_%j.log
#SBATCH --error=poly_only_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G

set -euo pipefail

module load BCFtools/1.18-GCC-12.3.0 || module load BCFtools || true
module load HTSlib/1.18-GCC-12.3.0   || module load HTSlib   || true

# =========================
# EDIT ONLY THIS
# =========================
IN_VCF="../joint_genotype/gwas_ready/gsoja_dp5_miss20.vcf.gz"
OUT_VCF="../joint_genotype/gwas_ready/gsoja_dp5_miss20_poly.vcf.gz"
# =========================

echo "[INFO] Input:  ${IN_VCF}"
echo "[INFO] Output: ${OUT_VCF}"

# Ensure AC/AN tags exist (computed on-the-fly), then drop monomorphic sites
bcftools +fill-tags -Ou "${IN_VCF}" -- -t AC,AN \
  | bcftools filter -e 'AC=0 || AC=AN' -Oz -o "${OUT_VCF}"

bcftools index -t "${OUT_VCF}"

echo "[INFO] Done."
bcftools stats "${OUT_VCF}" | grep -E "number of samples:|number of records:" || true
