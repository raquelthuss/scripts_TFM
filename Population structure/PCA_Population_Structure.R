###########################################################################
# 1. Import required files
###########################################################################

# Load packages
library(ggplot2)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(readODS)

rm(list=ls())
setwd("~/Desktop/1.LAB/TFM/structure/FAST_STRUCTURE_het_pruned_2/")

# Read PCA output files
pca <- read.table("dataset_pca.eigenvec", header = F)
eigenval <- read.table("dataset_pca.eigenval", header = F)$V1

colnames(pca) <- c("FID", "IID", paste0("PC", 1:(ncol(pca)-2)))

# Read coancestry matrix (Q-matrix) for the optimal K value
qmat <- read.table("Qmatrix_K3.txt", header = T, sep = "\t")

###########################################################################
# 2. Plot
###########################################################################

# Calculate explained variance by CP
CP_var <- round((eigenval / sum(eigenval)) * 100, 2)

# Asign cluster to every individual
qmat$Cluster <- apply(qmat[, paste0("Cluster", 1:3)], 1, function(x) {
  paste0("K", which.max(x))
})

# Verify same order of rows (ID)
all(pca$IID == qmat$Taxa)

# Plot
ggplot(pca, aes(x = PC1, y = PC2, color = qmat$Cluster)) + 
  geom_point(size = 2.5, alpha = 0.8) + 
  scale_color_manual(values = c("K1" = "#4e79a7",
                                "K2" = "#e15759",
                                "K3" = "#59a14f")) +
  labs(x = paste0("PC1 (", CP_var[1], "%)"),
       y = paste0("PC2 (", CP_var[2], "%)"),
       color = "Cluster") +
  theme_bw()
