## Description

This script 

# Comprimir el vcf
bgzip -k dataset_maf_001.vcf

# Indexar el vcf.gz
bcftools index dataset_maf_001.vcf.gz

# Extrar el SNP candidato
bcftools view -r glyso.PI483463.gnm1.Gs15:16165606-16165606 dataset_maf_001.vcf.gz -Oz -o snp_candidato.vcf.gz

# Convertir a tabla
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' snp_candidato.vcf.gz -H > genotipo_Gs15_16165606.txt
