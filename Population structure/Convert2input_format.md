## Step 1. Conversion to fastSTRUCTURE input format

### Description

Before running fastSTRUCTURE, two preprocessing steps are required.

First, a **linkage disequilibrium (LD)** pruning step is performed to remove SNPs that are tightly linked, retaining only unlinked, representative markers. This ensures that each SNP contributes independent information and prevents inflation of signals in downstream analyses. SNPs are pruned within a sliding window of 50 SNPs (shifting by 5) by removing one SNP from any pair with r² > 0.2.

Second, the pruned dataset is converted to the **binary PLINK format** (BED/BIM/FAM) required as input for fastSTRUCTURE. Both steps apply an additional filter retaining only SNPs with a minor allele frequency (MAF) ≥ 1%.
All processing is performed with **PLINK**.

### Usage

LD pruning: 

`plink --vcf gsoja.vcf.gz --maf 0.01 --indep-pairwise 50 5 0.2 --allow-extra-chr --out dataset`

Conversion to input format:

`plink --vcf gsoja.vcf.gz --maf 0.01 --extract dataset.prune.in --make-bed --allow-extra-chr --out final_dataset`

### Input

- LD pruning: filtered chromosome-level VCF file `gsoja.vcf.gz`
- Format conversion: SNPs that passed LD pruning `.prune.in`

### Outputs

- LD pruning: `.prune.in` (SNPs that passed LD filtering), `.prune.out`(SNPs removed during LD filtering) and `.log` (process log)
- Conversion to input format: `.bed` (genotypes in binary PLINK format), `.bim` (SNP information: chr, id, pos, alleles), `.fam` (sample information: family, individual, sex, phenotype) and `.log` (process log)

### Tools

- PLINK `v1.9.0-b.7.11`
