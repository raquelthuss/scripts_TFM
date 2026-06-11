# Step 4. Conversion to .vcf file

### Description

A **neighbor-joining tree** is constructed to further characterize population structure. The neccesary R script to accomplish this ("Phylogenetic_tree.R", also
included in this directory) requires an uncompressed VCF (Variant Call Format) as input, the pruned dataset (obtained in Step 2) is first converted in this step using **PLINK**.

### Usage

```bash
# Convert to .vcf
plink --bfile final_dataset --recode vcf --out final_dataset
```

### Input

- Pruned dataset converted to binary PLINK format `.bed/.bim/.fam`

### Output

- Variant Call Format file `.vcf`

### Tools

- PLINK `v1.9.0-b.7.11`
