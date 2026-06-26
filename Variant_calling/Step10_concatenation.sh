#!/bin/bash
#SBATCH --job-name=concat_allchr
#SBATCH --output=04_concat_%j.log
#SBATCH --error=04_concat_%j.err
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=raqthu@alum.us.es

set -euo pipefail

module load BCFtools/1.18-GCC-12.3.0 || true
module load HTSlib/1.18-GCC-12.3.0   || true

# =========================
INDIR="../joint_genotype/gatk_filtered_biallelic_maskGT_miss005"
OUT_VCF="../joint_genotype/gwas_ready/gsoja.vcf.gz"
THREADS="${SLURM_CPUS_PER_TASK:-1}"
# =========================

echo "============================================================"
echo "[INFO] Concatenating chromosomes"
echo "[INFO] Input dir : $INDIR"
echo "[INFO] Output    : $OUT_VCF"
echo "============================================================"

vcfs=()
for i in $(seq -w 1 20); do
  f="${INDIR}/Gs${i}_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz"
  [[ -f "$f" ]] || { echo "[ERROR] Missing $f"; exit 1; }
  vcfs+=("$f")
done

bcftools concat --threads "$THREADS" -Oz -o "$OUT_VCF" "${vcfs[@]}"
tabix -f -p vcf "$OUT_VCF"

echo "[DONE] $(bcftools index -n "$OUT_VCF") variants"
echo "============================================================"
