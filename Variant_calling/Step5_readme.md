## Step5. Joint genotyping with GenotypeGVCFs

### Description

In this step, each **GenomicsDB chunk** generated in **Step 4b** is genotyped with 
**GATK GenotypeGVCFs** to produce one VCF per interval. These chunk-level VCFs are then 
concatenated in numeric order to generate a final chromosome-level VCF.

The script performs two sequential jobs:

-   a **SLURM array job** to genotype each GenomicsDB interval independently
-   a **dependent gather job** to concatenate all chunk VCFs into a single chromosome level VCF

### Script summary

1.  Defines the chromosome and chunk size
2.  Reads the interval list generated in Step 4a
3.  Submits a **GenotypeGVCFs** SLURM array job, with one task per interval
4.  Writes one compressed VCF per chunk 
5.  Submits a dependent job to concatenate all chunk VCFs in numeric order
6.  Indexes the final chromosome VCF
7.  Reports per-chunk and final variant counts

### Inputs

-   GenomicsDB workspaces from Step 4b `../genomicsDB/genomicsdb_<GS>/gendb_<GS>_<interval>/`
-   Interval list from Step 4a `../genomicsDB/genomicsdb_<GS>/<GS>_<CHUNK>.intervals.list`
-   Reference genome `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

- Chunk-level VCFs

Written to: `../joint_genotype/genotyped_chunks_<GS>_<CHUNK>/`

Example:

```text
Gs01_chunk_1.vcf.gz  
Gs01_chunk_2.vcf.gz  
Gs01_chunk_3.vcf.gz
```
- Final chromosome VCF

Written to: `../joint_genotype/<GS>_genotyped_chunks.vcf.gz`

Example: `../joint_genotype/Gs01_genotyped_chunks.vcf.gz`

### Tools / modules

-   GATK v4.5.0.0
-   BCFtools v1.18
-   SLURM workload manager

### How to run on the cluster (SLURM)
