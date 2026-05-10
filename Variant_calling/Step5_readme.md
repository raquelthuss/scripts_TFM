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

-   GenomicsDB workspaces from Step 4b `../genomicsDB/genomicsdb_<GM>/gendb_<GM>_<interval>/`
-   Interval list from Step 4a `../genomicsDB/genomicsdb_<GM>/<GM>_<CHUNK>.intervals.list`
-   Reference genome `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

- Chunk-level VCFs: 
Written to: `../joint_genotype/genotyped_chunks_<GM>_<CHUNK>/`
