# Step 4. Conversion to .vcf file

### Description

A **neighbor-joining tree** is constructed to further characterize population structure. The required R script to perform this analysis (Phylogenetic_tree.R, also included in this directory) uses an uncompressed VCF (Variant Call Format) file as input. Therefore, the pruned dataset in binary PLINK format (generated in Step 1) is first converted using **PLINK** in this step.

### Usage

```bash
# Convert to .vcf
plink --bfile final_dataset --recode vcf --out final_dataset
```

### Input

- Pruned dataset in binary PLINK format `.bed/.bim/.fam`

### Output

- Pruned dataset converted to Variant Call Format `.vcf`

### Tools

- PLINK `v1.9.0-b.7.11`
