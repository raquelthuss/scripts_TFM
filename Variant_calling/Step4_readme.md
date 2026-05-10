# Step4. GenomicsDBImport per chromosome

## Description

In this step, per-sample gVCF files generated in the previous step are imported into a **GenomicsDB workspace** using **GATK GenomicsDBImport**. This is a intermediate step before joint genotyping with `GATK GenotypeGVCFs`.

To reduce memory usage and improve parallelization on HPC systems, the import is performed **per chromosome** and split into **fixed-size chunks**. 

For this reason, Step 4 is divided into two parts:

-   **Step 4a** – prepare the **sample map** and **interval list**
-   **Step 4b** – run `GenomicsDBImport` per interval using a **SLURM array job**

## Step 4a. Prepare sample map and interval list

### Script summary

1.  Defines the chromosome to process
2.  Defines the chunk size 
3.  Builds a **sample map** from chromosome-specific gVCF files
4.  Retrieves chromosome length from the reference `.fai` 
5.  Generates a list of genomic **intervals**

### Inputs

-   Chromosome-specific gVCFs   `../gvcf_batch/*.g.vcf.gz`
-   Reference genome    `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

Written to: `../genomicsDB/genomicsdb_<GM>/`

- sample map `sample_map_<GM>.txt`
- intervals list `<GM>_<CHUNK>.intervals.list`

### Example of sample map format

`sample`     `../Gs01/sample.g.vcf.gz`


