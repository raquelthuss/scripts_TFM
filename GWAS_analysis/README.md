## Description

This directory includes the scripts used to perform **GWAS analysis**, to identify maker-trait associations using **GAPIT**, incorporating genotype data, covariate data, and phenotype data. The worflow consists of the following steps:

- Step 1: Convert the chromosome-level .vcf.gz file to .vcf (Step1_Convert2vcf.md).
- Step 2: Convert the chromosome-level .vcf to HapMap format required by GAPIT (Conversion2hapmap.md).
- Step 3: Conduct a phenotype analysis.
- Step 4: Perform GWAS analysis with GAPIT.
- Step 5: Run linkage disequilibrium analysis to define LD blocks surrounding top candidates.

The R scripts used to generate phenotypic distribution plot, manhattan plot and boxplots can be found in this directory under the following names:

- Nodule_size_Distribution.R
- Manhattan_Plot.R
- Boxplot_SNP_Gs(16/11).R: boxplots showing phenotypic distribution across genotypic classes of candidate SNPs. The required genotypic data subset can be obtained using `Extract_genotype.md` script.
