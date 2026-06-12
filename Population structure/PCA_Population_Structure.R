###########################################################################
# 1. Import required files
###########################################################################

# Load packages
library(ggplot2)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(readODS)
library(stringr)

rm(list=ls())
setwd("~/Desktop/1.LAB/TFM/structure/FAST_STRUCTURE_het_pruned_2/")

# Read PCA output files
pca <- read.table("dataset_pca.eigenvec", header = F)
eigenval <- read.table("dataset_pca.eigenval", header = F)$V1

colnames(pca) <- c("FID", "Taxa", paste0("PC", 1:(ncol(pca)-2)))

# Read coancestry matrix (Q-matrix) for the optimal K value
qmat <- read.table("Qmatrix_K3.txt", header = T, sep = "\t")

# Read geographic distribution data
meta_data <- read_ods("meta.ods", sheet = 2)
meta_data <- meta_data[meta_data$Species == "G. soja", c("Orig_number", "Country")]
colnames(meta_data) <- c("Taxa", "Country")
meta_data$Taxa <- as.numeric(meta_data$Taxa)

###########################################################################
# 2. Plot
###########################################################################

# Calculate explained variance by CP
CP_var <- round((eigenval / sum(eigenval)) * 100, 2)

# Asign cluster to every individual
qmat$Cluster <- apply(qmat[, paste0("Cluster", 1:3)], 1, function(x) {
  paste0("K", which.max(x))
})

pca <- pca %>% 
  left_join(meta_data, by = "Taxa")

# Save the first letter of each country for subsequent plotting
pca$First_letter <- abbreviate(pca$Country, minlength = 2)

# Verify same order of rows (ID)
all(pca$IID == qmat$Taxa)

# Legend to indicate de country of origin from every sample
legend_text <- paste(pca$First_letter, pca$Country, sep = " = ", collapse = "\n")

# Plot
ggplot(pca, aes(x = PC1, y = PC2, color = qmat$Cluster)) + 
  geom_point(size = 2.5, alpha = 0.8) +
  geom_text_repel(aes(label = First_letter), 
                  size = 3,
                  max.overlaps = 25) +
  scale_color_manual(values = c("K1" = "#4e79a7",
                                "K2" = "#e15759",
                                "K3" = "#59a14f")) +
  
  labs(x = paste0("PC1 (", CP_var[1], "%)"),
       y = paste0("PC2 (", CP_var[2], "%)"),
       color = "Cluster") +
  theme_bw() 
