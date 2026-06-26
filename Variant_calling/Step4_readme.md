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

-   Chromosome-specific gVCFs   `../gvcf/*.g.vcf.gz`
-   Reference genome    `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

Written to: `../genomicsDB/genomicsdb_<GS>/`

- sample map `sample_map_<GS>.txt`
- intervals list `<GS>_<CHUNK>.intervals.list`

Example sample map for GS01:

```text
sample1       $HOME/tfm/genomicsDB/genomicsdb_Gs01/sample1.g.vcf.gz
sample1       $HOME/tfm/genomicsDB/genomicsdb_Gs01/sample2.g.vcf.gz
sample3       $HOME/tfm/genomicsDB/genomicsdb_Gs01/sample3.g.vcf.gz
```

Example intervals list for Gs01:

```text
glyso.PI483463.gnm1.Gs01:1-10000000
glyso.PI483463.gnm1.Gs01:10000001-20000000
glyso.PI483463.gnm1.Gs01:20000001-30000000
glyso.PI483463.gnm1.Gs01:30000001-40000000
glyso.PI483463.gnm1.Gs01:40000001-50000000
glyso.PI483463.gnm1.Gs01:50000001-57896170
```

### Tools / modules

-   Python – interval generation
-   SLURM workload manager

## Step 4b. Import to GenomicsDB workspace

### Script summary

1.  Defines the chromosome and chunk size
2.  Reads the **sample map**
3.  Reads the **interval list**
4.  Assigns one interval per SLURM task
5.  Runs `GenomicsDBImport`
6.  Creates one GenomicsDB workspace per interval

### Inputs

-   Sample map and intervals list from Step 4a   `sample_map_<GS>.txt`  `<GS>_<CHUNK>.intervals.list`
-   Chromosome-specific gVCFs
-   Reference genome:  `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

Written to: `../genomicsDB/genomicsdb_<GS>/`

- One workspace per interval:

Example for Gs01:

```text
gendb_Gs01_1_10000000
gendb_Gs01_10000001_20000000
gendb_Gs01_20000001_30000000
gendb_Gs01_30000001_40000000
gendb_Gs01_40000001_50000000
gendb_Gs01_50000001_57896170
```

## Tools / modules

-   GATK v4.5.0.0
-   SLURM workload manager

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of intervals `#SBATCH --array=1-6` 

2. Submit the job (see README.md)






