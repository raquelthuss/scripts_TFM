## Conversion from .BAM to .CRAM

### Description

In this step, optional but highly recommended, each **BAM** file produced in Step 2 is converted 
to the more storage-efficient **CRAM** format using **SAMtools**, reducing significantly disk 
space usage. Since Step 3 requires both the .bam and .bam.bai files, this conversion should only 
be run after Step 3 has been completed. Upon successful conversion, a **CRAI index** is generated 
for each CRAM file, and the original BAM along with its associated indices (.bai, .sbi) are 
removed to free up disk space.

### Script summary

1. 
