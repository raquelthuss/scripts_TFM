## Step 3. Per-sample variant calling in gVCF mode (HaplotypeCaller)

## Description

In this step, variants are called independently for each sample using **GATK HaplotypeCaller** 
in **gVCF mode**. Variant calling is performed **per chromosome** to improve scalability and 
resource usage on HPC systems.

The script is implemented as a **SLURM array job**, where each array task processes a single 
chromosome and iterates over all samples, producing one gVCF per **sample × chromosome**.

## Script summary

1.  Defines chromosome-specific genomic intervals.
2.  Assigns one interval per SLURM array task.
3.  Loops over all deduplicated BAM files.  
4.  Runs `gatk HaplotypeCaller` in gVCF mode for each sample and chromosome. 
5.  Writes compressed and indexed gVCF files for downstream joint genotyping.

## Inputs

-   Deduplicated BAM files: `..//bwa/*_sorted_dedup*.bam`
-   BAM index files: `.bam.bai`
-   Reference genome: `./ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`  
    (indexed for BWA, SAMtools, and GATK; see `Step2_readme`)

## Outputs

Written to `..//gvcf/`

For each sample and chromosome:

-   gVCF file: `<SAMPLE>_<REGION>.g.vcf.gz`
-   gVCF index: `<SAMPLE>_<REGION>.g.vcf.gz.tbi`
  
Example:
`1_glyso.PI483463.gnm1.Gs07:1-44817240.g.vcf.gz` 

## Genomic regions

Variant calling is performed separately for each of the 20 soybean chromosomes using fixed 
genomic intervals:

- `glyso.PI483463.gnm1.Gs01:1-57896170` (this is G. soja)
- `glyso.PI483463.gnm1.Gs02:1-51286261.g.vcf.gz`
...
- `glyso.PI483463.gnm1.Gs20:1-48820172.g.vcf.gz`

These intervals have been generated using this command:

awk '$1 ~ /\.Gs(0[1-9]|1[0-9]|20)$/ {print $1 ":1-" $2}' glyso.PI483463.gnm1.YJWS.genome_main.fna.fai

Each SLURM array task corresponds to **one chromosome**.

## Tools / modules

The following tools are loaded within the script:

-   **GATK** v4.5.0.0 – variant calling
-   **BCFtools** v1.18 – indexing support

## How to run on the cluster (SLURM)

1. Set the SLURM array range. The array size must match the number of chromosomes defined
   in the script: `#SBATCH --array=1-20` 

2. Submit the job (see README.md)

    
