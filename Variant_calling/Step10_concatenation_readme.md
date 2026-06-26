# Step 10. Concatenation of chromosome-level VCF files

## Description

In this step, chromosome-level VCF files are concatenated into a single genome-wide VCF file using **BCFtools concat**. This step merges the filtered variant datasets from all chromosomes into one file suitable for downstream analyses.

Concatenation is performed after chromosome-level filtering to improve performance and reduce memory usage.

## Script summary

1.  Defines the input directory containing chromosome-level VCF files
2.  Checks that all expected chromosome VCFs (`Gs01–Gs20`) are present
3.  Concatenates all chromosome VCF files using **bcftools concat**
4.  Compresses and indexes the final genome-wide VCF
5.  Reports the number of variants in the final file

## Inputs

- Chromosome-level genotyped VCF `../joint_genotype/gatk_filtered_biallelic_maskGT_dp5/<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz`

- Chromosome-level genotyped VCF Index `../joint_genotype/gatk_filtered_biallelic_maskGT_dp5/<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz.tbi`

```text
../joint_genotype/gatk_filtered/biallelic_maskGT_miss005/Gs01_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz 
../joint_genotype/gatk_filtered/biallelic_maskGT_miss005/Gs02_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz
...  
../joint_genotype/gatk_filtered/biallelic_maskGT_miss005/Gs20_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz
```

## Outputs

Written to `../joint_genotype/gwas_ready/`

- Genome-wide VCF file `gsoja.vcf.gz`

## Tools / modules

- BCFtools v1.18
- HTSlib v1.18
- SLURM workload manager

## How to run on the cluster (SLURM)

1. Submit the job (see README.md)
