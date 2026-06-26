# Extract genotypes for a top SNP

### Description

To generate a boxplot that displays the phenotypic distribution across genotypic classes of a specific SNP or variant candidate, it is required to extract the corresponding
genotypes from the genome-wide VCF file. 

### Usage

```bash
# Index .vcf.gz file
bcftools index dataset_maf_005.vcf.gz

# Extract the SNP of interest
bcftools view -r glyso.PI483463.gnm1.Gs16:12963807-12963807 dataset_maf_005.vcf.gz -Oz -o Gs16:12963807.vcf.gz

# Convert to table (.txt)
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' Gs16:12963807.vcf.gz -H > genotipo_Gs16_12963807.txt
```

### Input

- Pruned dataset `.vcf.gz`
- Pruned dataset index `.vcf.

### Output

- Table containing genotypes for the specified SNP `genotipo_Gs16_12963807.txt`

### Tools

- 
