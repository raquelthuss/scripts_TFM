# Step 1. Conversion to .vcf file

### Description

The GWAS analysis requires the genotype data to be in HapMap format. The required R script to perform this conversion (Conversion2hapmap.R, also included 
in this directory) uses an uncompressed VCF (Variant Call Format) file as input. Therefore, the pruned dataset is first converted
using **PLINK** in this step. Moreover, a minor allele frequency (MAF) filtering of 5% is done.

### Usage

```bash
# Convert to .vcf
plink --vcf gsoja_dp5_miss005_poly.vcf.gz --maf 0.05 --allow-extra-chr --recode vcf --out dataset_maf_005
```

### Input

- Pruned dataset `.vcf.gz`

### Output

- Pruned dataset converted to Variant Call Format `.vcf`

### Tools

- PLINK v1.9.0-b.7.11
