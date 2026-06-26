# Step 9. Chromosome-level filtering of missing genotypes

## Description

In this step, chromosome-level VCF files are filtered to retain only **high genotype-quality SNPs** that meet a **minimum sequencing depth**. Processing is performed **per chromosome** using a SLURM array job to reduce memory usage and improve scalability on HPC systems.

After masking in the previous step, the workflows **filters** sites based by missingness, retaining sites with less than 5% missing data. 

## Script summary

1. Defines the chromosome to process
2. Extracts SNPs from the input VCF
3. Filters based on missingness
4. Indexes all output VCFs
5. Reports variant counts before and after filtering

## Inputs

- Chromosome-level genotyped VCF `../joint_genotype/gatk_filtered_biallelic_maskGT_dp5/<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz`

- - Chromosome-level genotyped VCF Index `../joint_genotype/gatk_filtered_biallelic_maskGT_dp5/<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz.tbi`

## Outputs

Written to `../joint_genotype/gatk_filtered/biallelic_maskGT_miss005`

For each chromosome: 

- Chromosome-level genotyped VCF with SNPs with less then 5% missing data `<CHR>_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz`

- Chromosome-level genotyped VCF with SNPs with less then 5% missing data Index`<CHR>_GATK_snps_PASS_biallelic_maskGT_miss005.vcf.gz.tbi`

## Tools / modules

- BCFtools `v1.18`
- HTSlib `v1.18`
- SLURM workload manager

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of input VCF files `#SBATCH --array=1-20` 
2. Submit the job (see README.md)
