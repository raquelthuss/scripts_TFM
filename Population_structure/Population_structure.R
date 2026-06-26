# =============================================================================
# # Population structure analysis - Barplot
# =============================================================================

# Load packages
library(pophelper)
library(gridExtra)
library(dplyr)
library(tidyverse)
library(readODS)

rm(list=ls())
setwd("~/Desktop/1.LAB/TFM/structure/FAST_STRUCTURE_het_pruned_2/")

# =============================================================================
# 1. Import STRUCTURE output files
# =============================================================================

# Read fast-STRUCTURE output files
sfiles <- list.files(path = getwd(), pattern = "\\.meanQ$", full.names = TRUE)

sfiles_sorted <- sfiles[order(as.numeric(gsub("\\D", "", basename(sfiles))))]
slist <- readQ(files = sfiles_sorted, filetype = "basic",
               indlabfromfile = FALSE)

# =============================================================================
# 2. Generate Q-matrix for GAPIT
# =============================================================================

# Load and assign labels to the samples
ind_labels <- read.table("final_dataset.fam", header = FALSE)$V1
slist <- lapply(slist, function(q) {
  rownames(q) <- ind_labels
  return(q)
})

# Select the results corresponding to the optimal K value
slist_k3 <- alignK(slist[3])

# Get Q-matrix as data.frame
qmat <- as.data.frame(slist_k3)

# Add sample IDs as a column named 'Taxa' (required by GAPIT)
qmat$Taxa <- rownames(qmat)

# Reorder columns to have 'Taxa' first
qmat <- qmat[, c(ncol(qmat), 1:(ncol(qmat)-1))]

# Rename columns to Cluster1, Cluster2, Cluster3 for clarity
colnames(qmat)[2:4] <- paste0("Cluster", 1:3)

# Export Q-matrix for GAPIT
write.table(qmat, "Qmatrix_K3.txt", sep="\t", row.names=FALSE, quote=FALSE)

# =============================================================================
# 3. Prepare data for plot
# =============================================================================

# Load geographical data from samples
meta_data <- read_ods("meta.ods", sheet = 2)
meta_data <- meta_data[meta_data$Species == "G. soja", c("Orig_number", "Country")]
meta_data <- rename(meta_data, Taxa = Orig_number)
head(meta_data)

# Join Q-matrix with metadata
df <- qmat %>%
  left_join(meta_data, by = "Taxa")

# Order by countries
country_order <- c("Jp", "SK", "Rs", "Ch")

# Recode country labels and sort samples by country and cluster assignment
df <- df %>%
  mutate(Country = recode(Country,
                          "Japan"       = "Jp",
                          "South Korea" = "SK",
                          "Russia"      = "Rs",
                          "China"       = "Ch")) %>%
  mutate(Country = factor(Country, levels = country_order)) %>%
  arrange(Country, desc(Cluster3), desc(Cluster2), desc(Cluster1))

# Assign x-axis position
df <- df %>%
  mutate(sample_pos = row_number(),
         Taxa = factor(Taxa, levels = Taxa))

# Change to long format for ggplot
df_long <- df %>%
  pivot_longer(
    cols      = starts_with("Cluster"),
    names_to  = "Cluster",
    values_to = "Q"
  ) %>%
  mutate(Cluster = factor(Cluster, levels = c("Cluster1", "Cluster2", "Cluster3")))

# Generate country breaks for plot
country_breaks <- df %>%
  group_by(Country) %>%
  summarise(start = min(sample_pos), end = max(sample_pos), .groups = "drop") %>%
  mutate(mid = (start + end) / 2)

separators <- country_breaks$end[-nrow(country_breaks)] + 0.5

# Customize colors
cluster_colors  <- c("Cluster1" = "#0084B8",
                     "Cluster2" = "#8B0000",
                     "Cluster3" = "#008C04")

# =============================================================================
# 4. Plot
# =============================================================================

p <- ggplot(df_long, aes(x = factor(sample_pos), y = Q, fill = Cluster)) +
  
  geom_bar(stat = "identity", width = 1, linewidth = 0) +
  geom_vline(xintercept = separators, color = "white", linewidth = 0.8) +
  geom_text(
    data = country_breaks,
    aes(x = mid, y = -0.05, label = Country), 
    color = "black",
    size = 3.1, inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = cluster_colors,
    labels = c("Cluster 1", "Cluster 2", "Cluster 3")
  ) +
  scale_y_continuous(
    limits = c(-0.08, 1),
    breaks = seq(0, 1, 0.25),
    expand = c(0, 0)
  ) +
  scale_x_discrete(
    labels = setNames(as.character(df$Taxa), as.character(df$sample_pos))
  ) +
  labs(
    x    = NULL,
    y    = "Proportion of ancestry",
    fill = NULL
  ) +
  theme_classic(base_size = 11) +
  theme(
    axis.title.y     = element_text(margin = margin(r = 15), size = 12),
    axis.text.x      = element_blank(),
    axis.text.y      = element_text(size = 10), 
    axis.ticks.x     = element_blank(),
    axis.line.x      = element_blank(),
    panel.spacing    = unit(0, "lines"),
    legend.position  = "none",
    legend.key.size  = unit(0.7, "cm"),
    plot.margin      = margin(10, 10, 0, 10)
  )

# Save final plot
jpeg("Barplot.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

print(p)
dev.off()
