## Description

This directory includes the scripts and commands required for processing whole-genome sequencing (WGS) data and performing variant calling analyses, starting from raw Illumina FASTQ files and producing jointly genotyped VCF datasets.

The pipeline is designed to handle large-scale sequencing datasets through per-sample variant calling in gVCF mode, followed by chromosome-level joint genotyping. It is optimized for plant genomic analyses and has been tested using soybean whole-genome sequencing data from Glycine max and Glycine soja.

## Expected input structure

The scripts assume the following structure:
<pre><code>tfm/
|-- fasta/
|   |-- 1/
|   |   |-- sample1_lane1_1.fq.gz
|   |   |-- sample1_lane1_2.fq.gz
|   |-- 2/
|   |   |-- sample2_lane1_1.fq.gz
|   |   |-- sample2_lane1_2.fq.gz
|   |   |-- sample2_lane2_1.fq.gz
|   |   |-- sample2_lane2_2.fq.gz
|   |-- ...
|-- ref/
|   |-- glyso.PI483463.gnm1.YJWS.genome_main.fna
|-- scripts/
|   |-- Step1_FastQC.sh
|   |-- Step2a_Ref_genome_indexing.sh
|   |-- Step2b_BWA.sh
|   |-- Step3_HaplotypeCaller.sh
|   |-- ...
</code></pre>

There needs to be one folder per sample under `../fasta/`, with FASTQ files named as `*_1.fq.gz` and `*_2.fq.gz` (one or more lanes per sample).

The reference genome used in this pipeline is: **glyso.PI483463.gnm1.YJWS.genome_main.fna**

## How to run on the cluster (SLURM)

From the directory containing the script: 
`sbatch script.sh`

Job-specific log files will be generated for each array task:
- `<prefix>_<jobID>_<taskID>.log`
- `<prefix>_<jobID>_<taskID>.log`

where `<prefix>` corresponds to the executed step or tool (e.g., `bwa`, `gatk_haplotype`, `fastqc`, etc.).

