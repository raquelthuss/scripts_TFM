# =============================================================================
# Neighbor-joining tree
# =============================================================================

# Load packages
library(ape)
library(vcfR)
library(phangorn)
library(ggtree)
library(dplyr)
library(ggplot2)

rm(list=ls())
setwd("~/Desktop/1.LAB/TFM/structure/FAST_STRUCTURE_het_pruned_2/")

# =============================================================================
# 1. Data
# =============================================================================

# Read VCF file
vcf <- read.vcfR("final_dataset.vcf")

# Convert VCF to a genotype matrix (extracts GT and converts it to numeric)
gt <- extract.gt(vcf, element = "GT", as.numeric = TRUE)
colnames(gt) <- sub("^[^_]+_", "", colnames(gt))

# Read Q-matrix
qmat <- read.table("Qmatrix_K3.txt", header = T, sep = "\t")

# =============================================================================
# 2. Generate neighbor-joining tree
# =============================================================================

# Convert to distance matrix
dist_matrix <- dist.gene(as.matrix(t(gt)), method = "pairwise")

# Build neighbor-joining tree
nj_tree <- nj(dist_matrix)

# Root the tree at midpoint
nj_tree <- midpoint(nj_tree)

# =============================================================================
# 3. Plot
# =============================================================================

# Asign cluster to every individual
qmat$Cluster <- apply(qmat[, paste0("Cluster", 1:3)], 1, function(x) {
  paste0("K", which.max(x))
})

# Create a dataframe with specific column names required by ggtree
df_tree <- data.frame(taxa = qmat$Taxa, Cluster = qmat$Cluster)

# Plot
p <- ggtree(nj_tree, 
            layout = "rectangular", 
            size = 0.4, 
            color = "grey30") %<+% df_tree +
  
  geom_tippoint(aes(color = Cluster), 
                size = 1, 
                alpha = 0.9) +
  
  scale_color_manual(values = c("K1" = "#0084B8",
                                "K2" = "#8B0000",
                                "K3" = "#008C04")) +
  
  theme_tree2() + 
  theme(        
    legend.position = "none",
    axis.text.x = element_blank(),
    axis.line.x = element_blank(),
    axis.ticks.x = element_blank()
  )

# Manually rotate specific internal nodes to optimize tree topology visualization
p <- rotate(p, 113)
p <- rotate(p, 77)
p <- rotate(p, 79)

# Save final plot
jpeg("Neighbor_joining_tree.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

print(p)
dev.off()
