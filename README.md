# NGS Analysis Pipelines: Variant Calling, Population Structure & GWAS

## Overview

This repository contains the pipelines developed for my Master’s final project focused on the bioinformatic analysis of whole-genome sequencing (WGS) data. It includes variant calling and filtering, population structure characterization, and genome-wide association studies (GWAS) to identify genetic variants associated with phenotypic traits. It is designed for execution on high-performance computing (HPC) systems using SLURM.

## 1. Variant calling

This directory includes the scripts and commands required for processing whole-genome sequencing (WGS) data and performing variant calling analyses, starting from raw Illumina FASTQ files and producing jointly genotyped VCF datasets.

The pipeline is designed to handle large-scale sequencing datasets through per-sample variant calling in gVCF mode, followed by chromosome-level joint genotyping. It is optimized for plant genomic analyses and has been tested using soybean whole-genome sequencing data from *Glycine max* and *Glycine soja*.

## 2. Population structure

## 3. GWAS (Genome-Wide Associations Studies)
