## Step 3. Generate PCA files

### Description

In order to visualize genetic structure within a population a **Principal Component Analysis**
(PCA) can be perform. A pruned dataset (LD, MAF) in binary PLINK format is required. Using **PLINK** 
eigenvectors and eigenvalues are generated, that can be imported in R and be plotted. 

### Usage

```bash

# Perform PCA
plink --bfile final_dataset --pca --allow-extra-chr --out dataset_pca
```

### Input

### Output

### Tools

- PLINK 
