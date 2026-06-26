# Convertir el archivo de los SNPs en formato PLINK
plink --vcf gsoja_dp5_miss20_poly.vcf.gz  --make-bed --maf 0.05 --out ../LD/snps --allow-extra-chr

# Diagnostico de cada SNP (es decir, ver el LD con todos los SNPs posibles en una region dada)
plink --bfile snps --ld-snp glyso.PI483463.gnm1.Gs15:16165606:G-A --ld-window-kb 99999 --ld-window 400 --ld-window-r2 0.0 --out LD_Gs15:16165606:G-A --r2 --allow-extra-chr

# Diagnostico de cada SNP 2 (ver el LD con todos los SNPs posibles en todo el genoma)
plink --bfile ../snps --ld-snp glyso.PI483463.gnm1.Gs15:16165606:G-A --ld-window-kb 999999 --ld-window 999999 --ld-window-r2 0.0 --chr glyso.PI483463.gnm1.Gs15 --out Gs15:16165606:G-A_whole_chr --r2 --allow-extra-chr

# Encontrar SNPs en la región
plink --bfile snps --ld-snp glyso.PI483463.gnm1.Gs15:16165606:G-A --ld-window-kb 250 --ld-window 99999 --ld-window-r2 0.6 --out LD_Gs15:16165606:G-A --r2 --allow-extra-chr
