# Step 2. Reference genome indexing and Read alignment

## Description

This step aligns paired-end reads to the reference genome with **BWA-MEM**, handles 
**multiple sequencing lanes per sample** using lane-specific read groups, merges lanes 
into a single BAM per sample, marks duplicates, and produces basic alignment/QC metrics. 
It is implemented as a **SLURM array job**, where each array task processes **one sample 
folder**. 

Before running the alignment step, the reference genome must be indexed for **BWA**, **SAMtools**, and **GATK**. These index files are required for read alignment, BAM processing, and all downstream variant calling steps. This only needs to be performed one per reference genome.

This step is divided in two parts:

- **Step 2a** - Reference genome indexing
- **Step 2b** - Read alignment and BAM generation

## Step 2a. Reference genome indexing

## Script summary

1. Creates the BWA index files required for read alignment.
2. Creates the FASTA index required by SAMtools and GATK.
3. Creates the sequence dictionary required by GATK tools.

## Inputs

- Reference genome: `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

## Outputs

Written to: `../ref`

- BWA index files: `.fna.amb`, `.fna.ann`, `.fna.bwt`, `.fna.pac`, `.fna.sa`
- SAMtools index file: `.fna.fai`
- GATK sequence dictionary: `.dict`

## Tools / modules

Loaded within the script:
- BWA `0.7.17`
- SAMtools `1.17`
- GATK `4.5.0.0`

## Step 2b. Read alignment and BAM generation

## Script summary

1. Align each lane independently with BWA-MEM and add a lane-specific read group (`@RG`).
2. Sort alignments per lane and write a lane BAM.
3. Merge lanes to create one BAM per sample (or copy if only one lane).
4. Mark duplicates to create a final deduplicated BAM + index.
5. Generate QC metrics (WGS metrics, alignment summary, insert size).

## Inputs

- Paired-end reads: `../fasta/<SAMPLE>/*_1.fq.gz` and `*_2.fq.gz`
- Reference genome: `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna` (must be indexed)

## Outputs

Written to: `../bwa/`

Per sample:
- Final deduplicated BAM: `<SAMPLE>_sorted_dedup.bam`
- BAM index: `<SAMPLE>_sorted_dedup.bam.bai`
- QC metrics:
  - `<SAMPLE>_wgs_metrics.txt`
  - `<SAMPLE>_alignment_metrics.txt`
  - `<SAMPLE>_insert_size.txt`
  - `<SAMPLE>_insert_size.pdf`

Intermediate files (removed by default):
- Per-lane BAMs: `<SAMPLE>_<RGID>_sorted.bam`
- Merged BAM: `<SAMPLE>_sorted.bam`

## Tools / modules

Loaded within the script:

- BWA `0.7.17`
- SAMtools `1.17`
- GATK `4.5.0.0`
- R – required by GATK to generate insert size histogram PDFs (`CollectInsertSizeMetrics`)


## How to run on the cluster (SLURM)

1. Set the SLURM array range. Edit the SLURM header to match the number of sample directories in `../fasta/` : `#SBATCH --array=1-n` 

2. Submit the job (see README.md)
