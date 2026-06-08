## Step 3. Generate PCA files

### Description

A **Principal Component Analysis** (PCA) is perform to visualize genetic structure within a population. A pruned dataset (LD, MAF) 
in binary PLINK format is required. **PLINK** is used to compute eigenvectors and eigenvalues which can be imported in R for visualization. 

### Usage

```bash

# Perform PCA
plink --bfile final_dataset --pca --allow-extra-chr --out dataset_pca
```

### Input

- Pruned dataset converted to binary PLINK format `.bed/.bim/.fam`

### Output

- Per-individual PC coordinates `.eigenvec`
- Variance explained by each principal component `.eigenval`

### Tools

- PLINK `v1.9.0-b.7.11`
