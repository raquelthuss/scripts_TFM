# =============================================================================
## Conversion from vcf to hapmap for GAPIT
# =============================================================================

setwd("~/Desktop/1.LAB/TFM/GAPIT")
library(vcfR)

# Read vcf
vcf_data <- read.vcfR("dataset_maf_005.vcf")
class(vcf_data)

# Convert to hapmap
myHapMap <- vcfR2hapmap(vcf_data)

# Convert to dataframe for subsequent column renaiming
myHapMap <- as.data.frame(myHapMap, check.names = FALSE)

# Rename first 11 columns for GAPIT
colnames(myHapMap)[1:11] <- c("rs#", "alleles", "chrom", "pos", "strand", 
                              "assembly#", "center", "protLSID", "assayLSID", 
                              "panel", "QCcode")
myHapMap <- myHapMap[2:nrow(myHapMap),]

# Save hapmap
write.table(myHapMap, 
            file = "myHapMap.hmp.txt",
            sep = "\t", 
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE)
