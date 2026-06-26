# Step 11. Genome-wide VCF polymorphic filtering

## Description

In this step, a genome-wide VCF file is filtered to retain only **polymorphic SNPs** and remove monomorphic variants. This filtering step reduces noise and improves downstream analysis. 

## Script summary

1.  Computes allele count (AC) and allele number (AN)
2.  Filters out variants where no alternate alleles are present (AC=0) or where all alleles are alternate (AC=AN)
3.  Compresses and indexes the output VCF
4.  Reports the number of variants in the final file

## Inputs

- Genome-wide VCF file `../joint_genotype/gwas_ready/gsoja.vcf.gz`

## Outputs

Written to `../joint_genotype/gwas_ready/`

- Genome-wide VCF file with polymorphic SNPs `gsoja_poly.vcf.gz`
- Genome-wide VCF file with polymorphic SNPs Index `gsoja_poly.vcf.gz.tbi`

## Tools / modules

- BCFtools `v1.18`
- HTSlib `v1.18`

## How to run on the cluster (SLURM)

1. Submit the job (see README.md)
