## Linkage Disequilibrium (LD) analysis

### Description

In order to determine the **linkage disequilibrium (LD) block** surrounding SNP candidates, **pairwise r² values** are calculated. 
First, the pruned dataset is converted to the **binary PLINK format** (BED/BIM/FAM) with a minor allele frequency (MAF) filter of 5%. Second, r² values are calculated between the candidate SNP (in this example: `glyso.PI483463.gnm1.Gs16:13661213:G-T`) and all variants across the chromosome where it is localted. The final output defines the LD block associated with the SNP of interest based on the r² > 0.6 cutoff. All processing is performed with **PLINK**.

### Usage

```bash
# Conversion to input format
plink --vcf gsoja_dp5_miss20_poly.vcf.gz  --make-bed --maf 0.05 --out ../LD/snps --allow-extra-chr

# Calculate r² along the whole chromosome
plink --bfile ../snps --ld-snp glyso.PI483463.gnm1.Gs16:13661213:G-T --ld-window-kb 999999 --ld-window 999999 --ld-window-r2 0.0 --chr glyso.PI483463.gnm1.Gs16 --out Gs16:13661213:G-T_whole_chr --r2 --allow-extra-chr

# Define LD block according to a threshold of r² > 0.6
plink --bfile snps --ld-snp glyso.PI483463.gnm1.Gs16:13661213:G-T --ld-window-kb 999999 --ld-window 99999 --ld-window-r2 0.6 --out LD_Gs16:13661213:G-T --r2 --allow-extra-chr
```

### Input

- Filtered chromosome-level VCF file `.vcf.gz`

### Outputs

- Conversion to input format: `.bed` (genotypes in binary PLINK format), `.bim` (SNP information: chr, id, pos, alleles), `.fam` (sample information: family, individual, sex, phenotype) and `.log` (process log)
- LD block identification: binary PLINK format (BED/BIM/FAM)

### Tools

- PLINK `v1.9.0-b.7.11`
