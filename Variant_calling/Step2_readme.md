# Step 2. Reference genome indexing and Read alignment

## Description

This step aligns paired-end reads to the reference genome with **BWA-MEM**, handles 
**multiple sequencing lanes per sample** using lane-specific read groups, merges lanes 
into a single BAM per sample, marks duplicates, and produces basic alignment/QC metrics. 
It is implemented as a **SLURM array job**, where each array task processes **one sample 
folder**. 

Before running the alignment, the reference genome must be indexed. These index files are
required for read alignment, BAM processing, and all downstream variant calling steps. 
For this reason, this step is divided in two parts:

- **Step 2a** - Reference genome indexing
- **Step 2b** - Read alignment and BAM generation

## Step 2a. Reference genome indexing

## Description

This steps generates index files required by **BWA**, **SAMtools** and **GATK**. This only
needs to be performed one per reference genome.

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

