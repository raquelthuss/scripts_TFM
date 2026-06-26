# Step 7. Chromosome-level filtering of biallelic SNPs

## Description

In this step, chromosome-level VCF files are filtered to retain only **high-quality, bialleic SNPs**. Processing is performed **per chromosome** using a SLURM array job to reduce memory usage and improve scalability on HPC systems.

The workflow extracts SNPs from the input VCF, applies **GATK VariantFiltration** to label low-quality variants, retains only those with `PASS` status, and further filters to keep only biallelic sites. 

SNP quality filter: `QD < 26.0 || FS > 60.0 || MQ < 40.0`

Biallelic filter: `SNPs with exactly 2 alleles`

## Script summary

1. Defines the chromosome to process
2. Extracts SNPs from the input VCF
3. Applies **GATK VariantFiltration** using quality thresholds
4. Keeps only SNPs with `PASS` status
5. Filters to retain only biallelic PASS SNPs
6. Indexes all output VCFs
7. Reports variant counts before and after filtering

## Inputs

- Chromosome-level genotyped VCF `../joint_genotype/vcf_with_SNP_IDs/<CHR>_genotyped_chunks_ID.vcf.gz`
- Reference genome `../ref/glyso.PI483463.gnm1.YWS.genome_main.fna`

## Outputs

Written to `../joint_genotype/gatk_snps_filtered/`

For each chromosome: 

- Chromosome-level genotyped VCF with SNPs with PASS status `<CHR>_GATK_snps_PASS.vcf.gz`
- Chromosome-level genotyped VCF with biallelic PASS SNPs `<CHR>_GATK_snps_PASS_biallelic.vcf.gz`
- Chromosome-level genotyped VCF with biallelic PASS SNPs Index `<CHR>_GATK_snps_PASS_biallelic.vcf.gz.tbi`

## Tools / modules

- GATK `v4.5.0.0`
- BCFtools `v1.18`
- HTSlib `v1.18`
- SLURM workload manager

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of input VCF files `#SBATCH --array=1-20` 
2. Submit the job (see README.md)
