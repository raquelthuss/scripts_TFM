## Conversion from .BAM to .CRAM

### Description

In this step, optional but highly recommended, each **BAM** file produced in Step 2 is converted 
to the more storage-efficient **CRAM** format using **SAMtools**, reducing significantly disk 
space usage. Since Step 3 requires both the .bam and .bam.bai files, this conversion should only 
be run after Step 3 has been completed. Upon successful conversion, a **CRAI index** is generated 
for each CRAM file, and the original BAM along with its associated indices (.bai, .sbi) are 
removed to free up disk space.

### Script summary

1. Loops over all BAM files found in the input directory.
2. Converts each BAM to CRAM format using `samtools view` with the provided reference genome.
3. Generates a CRAI index for each successfully converted CRAM file.
4. Removes the original BAM file and its associated indices (.bai, .sbi).

### Inputs

- BAM and BAM index: `../bwa/`
- Reference genome: `../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna`

### Outputs

Written to: `../bwa/`

- CRAM and CRAM index: `sample_sorted_dedup.cram` `sample_sorted_dedup.cram.crai`

### Tools

- SAMtools `1.17`

### How to run on the cluster (SLURM)

sbatch Conversion2cram.sh
