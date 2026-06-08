## Description

In order to run fastSTRUCTURE, it is neccessary to convert the filtered chromosome-level gVCF file generated in the previous step to the input structure format. 
Before that, a **linkage dissequilibrium (LD) pruning** step must be performed to exclude SNPs that are tightly linked (high LD), leaving a dataset of unlinked, 
representative markers. This ensures that each SNP contributes independent information to the analysis and does not inflate signals in population structure.

In this workflow, **PLINK** is aplied to remove SNPs in high linkage disequilibrium (LD) within a 50 SNP window, shifting by 5 SNPs and removing one of any 
pair with r² > 0.2. Moreover, an additional filtering step retained only SNPs with a minor allele frequency (MAF) ≥ 1%. 

## 
After the installation, **PLINK** can be run from the command line like followes:
`plink --vcf gsoja.vcf.gz --maf 0.01 --indep-pairwise 50 5 0.2 --out dataset_pruned --allow-extra-chr`

The conversion to the input format can be done like: 
`plink --vcf gsoja.vcf.gz --maf 0.01 --extract dataset_pruned.prune.in --make-bed --out dataset_filtered --allow-extra-chr`


## Input

- Filtered chromosome-level gVCF file: `gsoja.vcf.gz`

## Outputs

- `dataset_pruned.prune.in` : SNPs that PASS LD filtering
- `dataset_pruned.prune.out`: SNPs that do not PASS LD filtering
- `dataset_pruned.log`: log file of the process

- `dataset_filtered.bed`: genotypes in binary PLINK format
- `dataset_filtered.bim`: information about the SNPs (chr, id, pos, alleles)
- `dataset_filtered.fam`: information about the samples (family, individual, sex, phenotype)
- `dataset_filtered.log`: log file of the process

## Tools

- PLINK: `v1.9.0-b.7.11`
