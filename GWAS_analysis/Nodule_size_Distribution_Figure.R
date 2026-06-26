# =============================================================================
# Trait distribution across genotypes
# =============================================================================

rm(list = ls())
setwd("~/Desktop/1.LAB/TFM/phenotype/")

library(readxl)
library(tidyverse)
library(readxl)
library(dplyr)
library(purrr)
library(ggplot2)

# ==========================================================
# 1. Data
# ==========================================================

# Load phenotyping data
sheet_names <- excel_sheets("./results_GWAS.xlsx")
df <- map_dfr(sheet_names, ~ {
  read_excel(
    "./results_GWAS.xlsx",
    sheet = .x,
    col_types = "text"
  )
})

# Load sample metadata
meta <- read_excel( "./meta.xlsx", sheet = 2) %>% select(Orig_number,Species)

# Merge phenotype with metadata using accession ID
df <- df %>%
  inner_join(
    meta,
    by = "Orig_number"
  )

# Remove non inoculated control samples, outliers and samples with 0 nodules
df <- df %>%
  filter(
    !(GWAS_num %in% c("control_1_NI","control_2_NI","control_3_NI")),
    is.na(Outliers) | Outliers == "")

# New dataframe
weight_per_nodule_df <- df %>%
  filter(Species %in% c("G. max", "G. soja")) %>%
  mutate(Weight_per_nodule = as.numeric(Weight_per_nodule)) %>% 
  group_by(Orig_number, Species) %>%
  # Calculate summary statistics per accession
  summarise(Mean_weight_per_nodule = mean(Weight_per_nodule, na.rm = TRUE),
    n_rep = n(),
    se_weight_per_nodule = sd(
      Weight_per_nodule,
      na.rm = TRUE) / sqrt(n_rep),
    .groups = "drop"
  )

head(weight_per_nodule_df)

# Filter for G. soja
weight_per_nodule_gsoja <- weight_per_nodule_df %>% filter(Species == "G. soja")

# ==========================================================
# 2. Plot
# ==========================================================

p <- ggplot(
  weight_per_nodule_gsoja %>% arrange(Mean_weight_per_nodule),
  aes(
    x = reorder(Orig_number, Mean_weight_per_nodule),
    y = Mean_weight_per_nodule
  )
) +
  geom_col(fill = "#008C04") +
  geom_errorbar(
    aes(
      ymin = Mean_weight_per_nodule - se_weight_per_nodule,
      ymax = Mean_weight_per_nodule + se_weight_per_nodule
    ),
    width = 0.2,
    linewidth = 0.3
  ) +
  annotate(
    "text", 
    x = 3,
    y = 0.011,
    label = "ANOVA:~italic(F)(73, 1723) == 12.59*','~italic(p) < 0.001",
    parse = T,
    hjust = 0,
    size = 3,
    fontface = "italic"
  ) +
  scale_y_continuous(expand = c(0.01, 0), 
                     limits = c(0, 0.012),
                     breaks = seq(0, 0.012, by = 0.002),
                     labels = scales::label_number(accuracy = 0.001)) +

  theme_classic(base_size = 11) +
  labs(
    x = "Accessions",
    y = "Nodule size (g)"
  ) +
  theme(
    axis.title.x = element_text(size = 12, margin = margin(t = 10)),
    axis.title.y = element_text(size = 12, margin = margin(r = 15)),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.ticks.x = element_blank(),
    axis.line = element_line(linewidth = 0.5),
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

  
jpeg("Phenotype.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)  

print(p)

dev.off()
