# Step 6. Assign SNP names

## Description

In this step, chromosome-level genotyped VCF files are processed to **assign a unique ID to every variant** build from its coordinates (chromosome and position) and alleles (reference and alternative). It is implemented as a **SLURM array job**, where each array task processes one chromosome. 

## Script summary

1. Defines the chromosome to process
2. Assigns a unique ID to every variant using the format `%CHROM:%POS:%REF-%ALT`
3. Indexes the output VCF
4. Reports a sanity check: first 3 records and count of variant missing an ID

## Inputs

- Chromosome-level genotyped VCFs `../joint_genotype/Gs*_genotyped_chuncks.vcf.gz

## Outputs

Written to `../joint_genotype/vcf_SNP_IDs/`

For each chromosome: 

- Chromosome-level genotype VCFs with SNP ID `<CHR>_genotyped_chuncks_ID.vcf.gz`

Example of IDs:
`glyso.PI483463.gnm1.Gs01:1245780:A-G`
`glyso.PI483463.gnm1.Gs01:3489021:TC-T`

## Tools / modules

- BCFtools v1.18
- HTSlib v1.18
- SLURM workload manager

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of input VCF files `#SBATCH --array=0-19` 
2. Submit the job (see README.md)
