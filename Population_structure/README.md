## Description

This directory includes the commands used to assess **population structure**, a key step prior to GWAS. In structured populations, allele frequencies may vary systematically between subgroups due to shared ancestry, which can introduce spurious associations and inflate test statistics, leading to false positives. 

To adress this, **fastSTRUCTURE** is applied, a Bayesian clustering algorithm for large SNP datasets. The worflow consists of the following steps: 

- Step 1: Convert the chromosome-level VCF file to binary PLINK format (required input for fastSTRUCTURE).
- Step 2: Run fastSTRUCTURE across a range of K values and determine the optimal number of clusters.
- Step 3: Perform a Principal Component Analysis (PCA) to visualize population structure.
- Step 4: Convert dataset in binary PLINK format to Variant Call Format (VCF) to allow neighbor-joining tree construction.

The **R scripts** used to generate the barplots, PCA and neighbor-joining tree can be found in this directory under the following names: 

- Population_Structure.R
- PCA.R
- Neighbor_joining_tree.R
