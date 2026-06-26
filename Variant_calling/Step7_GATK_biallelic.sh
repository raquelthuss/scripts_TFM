#!/bin/bash
#SBATCH --job-name=gatk_snps_pass
#SBATCH --output=00_gatk_snps_pass_%A_%a.log
#SBATCH --error=00_gatk_snps_pass_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --array=1-20
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=raqthu@alum.us.es

set -euo pipefail

module purge 2>/dev/null || true
module load GATK/4.5.0.0-GCCcore-12.3.0-Java-17
module load BCFtools/1.18-GCC-12.3.0
module load HTSlib/1.18-GCC-12.3.0 2>/dev/null || true

# =========================
# EDIT ONLY THIS
# =========================
REFERENCE="../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna"
INDIR="../joint_genotype/vcf_with_SNP_IDs"
OUTDIR="../joint_genotype/gatk_snps_filtered"

# Your SNP hard-filter expression
SNP_FILTER_EXPR="QD < 26.0 || FS > 60.0 || MQ < 40.0"
# =========================

mkdir -p "$OUTDIR" logs

CHR=$(printf "Gs%02d" "$SLURM_ARRAY_TASK_ID")

VCF_IN="${INDIR}/${CHR}_genotyped_chunks_ID.vcf.gz"

SNP_PASS="${OUTDIR}/${CHR}_GATK_snps_PASS.vcf.gz"
SNP_PASS_BIAL="${OUTDIR}/${CHR}_GATK_snps_PASS_biallelic.vcf.gz"

TMPDIR=$(mktemp -d "${OUTDIR}/GW_tmp.${CHR}.XXXXXX")
trap 'rm -rf "$TMPDIR"' EXIT

TMP_SNP="${TMPDIR}/${CHR}_snps_tmp.vcf.gz"
SNP_LABELED="${TMPDIR}/${CHR}_snps_labeled.vcf.gz"

echo "============================================================"
echo "[INFO] Chr        : $CHR"
echo "[INFO] Input VCF  : $VCF_IN"
echo "[INFO] Reference  : $REFERENCE"
echo "[INFO] Outdir     : $OUTDIR"
echo "[INFO] Filter     : $SNP_FILTER_EXPR"
echo "============================================================"
date

[[ -f "$VCF_IN" ]] || { echo "[ERROR] Missing input VCF: $VCF_IN"; exit 1; }
[[ -f "$REFERENCE" ]] || { echo "[ERROR] Missing reference: $REFERENCE"; exit 1; }

# index input if needed
if [[ ! -f "${VCF_IN}.tbi" && ! -f "${VCF_IN}.csi" ]]; then
  echo "[INFO] Input index missing -> tabix indexing"
  tabix -p vcf "$VCF_IN"
fi

count_records () { bcftools view -H "$1" | wc -l; }

echo "=== COUNTS BEFORE ==="
TOTAL_SNPS=$(bcftools view -H -v snps "$VCF_IN" | wc -l)
echo "SNPs in input: $TOTAL_SNPS"
echo "------------------------------------------------------------"

echo "=== EXTRACT SNPs (TEMP) ==="
bcftools view -v snps -Oz -o "$TMP_SNP" "$VCF_IN"
gatk IndexFeatureFile -I "$TMP_SNP"
echo "------------------------------------------------------------"

echo "=== GATK VariantFiltration (label SNPs) ==="
gatk VariantFiltration \
  -R "$REFERENCE" \
  -V "$TMP_SNP" \
  --filter-name "SNP_filter" \
  --filter-expression "$SNP_FILTER_EXPR" \
  -O "$SNP_LABELED"
gatk IndexFeatureFile -I "$SNP_LABELED"
echo "------------------------------------------------------------"

echo "=== KEEP PASS SNPs ONLY ==="
bcftools view -f PASS -Oz -o "$SNP_PASS" "$SNP_LABELED"
tabix -f -p vcf "$SNP_PASS"
echo "------------------------------------------------------------"

echo "=== KEEP PASS + BIALLELIC SNPs ONLY ==="
bcftools view -m2 -M2 -Oz -o "$SNP_PASS_BIAL" "$SNP_PASS"
tabix -f -p vcf "$SNP_PASS_BIAL"
echo "------------------------------------------------------------"

echo "=== COUNTS AFTER ==="
SNPS_PASS=$(count_records "$SNP_PASS")
SNPS_PASS_BIAL=$(count_records "$SNP_PASS_BIAL")
echo "SNPs PASS          : $SNPS_PASS"
echo "SNPs PASS biallelic: $SNPS_PASS_BIAL"
echo "============================================================"
echo "[DONE] Outputs:"
echo "  $SNP_PASS"
echo "  $SNP_PASS_BIAL"
echo "============================================================"
date
