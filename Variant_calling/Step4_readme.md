# Step4. GenomicsDBImport per chromosome

## Description

In this step, per-sample gVCF files generated in the previous step are imported into a **GenomicsDB workspace** using **GATK GenomicsDBImport**. This is a intermediate step before joint genotyping with `GATK GenotypeGVCFs`.
To reduce memory usage and improve parallelization on HPC systems, the import is performed **per chromosome** and split into **fixed-size chunks**. For this reason, Step 4 is divided into two parts:

-   **Step 4a** – prepare the **sample map** and **interval list**
-   **Step 4b** – run `GenomicsDBImport` per interval using a **SLURM array job**

