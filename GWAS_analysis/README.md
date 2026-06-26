## Description

This directory includes the scripts used to perform **GWAS analysis**, to identify maker-trait associations using **GAPIT**, incorporating genotype data, covariate data, and phenotype data. 
Each script contains the necessary commands to run:

- **Phenotype_Analysis.R**: analysis of phenotype distribution using a Gamma GLMM and extraction of estimated marginal means
  
- **Nodule_size_Distribution.R**: bar plot showing phenotypic variations across genotypes

- **Conversion2hapmap.R**: conversion of genotype data (.vcf) to HapMap format required by GAPIT.
  
- **GAPIT.R**: GWAS analysis with multiple statistical models
  
- **Manhattan_Plot.R**: manhattan plot showing -log10(p-values) across the 20 chromosomes for three statistical models
  
- **Boxplot_SNP_Gs(16/11).R**: boxplots showing nodule size distribution across genotypic classes of SNP 
Gs16:12963807:G-A and Gs11:36243818:C-T, respectively.

- **Linkage_disequilibrium_analysis.R**: linkage disequilibrium (LD) block definition surrounding top SNPs  
