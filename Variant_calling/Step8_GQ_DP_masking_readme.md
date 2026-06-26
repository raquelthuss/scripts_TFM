## Description

In this step, chromosome-level VCF files are scanned to flag that do not meet **genotype-quality** or **minimum sequencing depth** thresholds. Processing is performed **per chromosome** using a SLURM array job to reduce memory usage and improve scalability on HPC systems.

The workflows **masks** these SNPs, that are going to be removed in the next step.

Genotype quality filter: `GQ > 20`
Min depth: `DP > 5`

## Script summary

1. Defines the chromosome to process.
2. Checks whether there is a GQ field in the VCF header. 
3. Builds filter expression. Starts from DP < MIN_DP and conditionally appends DP > MAX_DP (if MAX_DP != 0) and FMT/GQ < MIN_GQ (if MIN_GQ != 0).
4. Applies the expression and sets GT to . (missing) if the condition is met.
5. Indexes all output VCFs
6. Reports variant counts before and after filtering (should stay the same, genotypes get label, not removed). 

## Inputs

- Chromosome-level genotyped VCF (high-quality biallelic SNPs) `../joint_genotype/vcf_with_SNP_IDs/gatk_snps_filtered/<CHR>_GATK_snps_PASS_biallelic.vcf.gz`

- Chromosome-level genotyped VCF (high-quality biallelic SNPs) Index `../joint_genotype/vcf_with_SNP_IDs/gatk_snps_filtered/<CHR>_GATK_snps_PASS_biallelic.vcf.gz.tbi`

## Outputs

Written to `../joint_genotype/gatk_snps_filtered/gatk_filtered_biallelic_maskGT_dp5`

For each chromosome:

- Chromosome-level genotyped VCF with masked SNPs `<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz`

- Chromosome-level genotyped VCF with masked SNPs Index `<CHR>_GATK_snps_PASS_biallelic_maskGT.vcf.gz.tbi`

## Tools / Modules

- BCFtools v1.18
- HTSlib v1.18
- SLURM workload manager

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of input VCF files `#SBATCH --array=1-20` 
2. Submit the job (see README.md)
