# =============================================================================
# Overlayed Manhattan Plot
# =============================================================================

library(tidyverse)
library(ggplot2)

rm(list = ls())
setwd("~/Desktop/1.LAB/TFM/Overlayed_Manhattan_Cat")

# =============================================================================
# Data
# =============================================================================

farmcpu <- read.csv("GAPIT.Association.GWAS_Results.FarmCPU.Pheno(NYC).csv")
blink    <- read.csv("GAPIT.Association.GWAS_Results.BLINK.Pheno(Kansas).csv")
mlmm <- read.csv("GAPIT.Association.GWAS_Results.MLMM.Pheno(NYC).csv")

# Extracts and normalizes chromosome numbers
get_chr_num <- function(x) {
  x <- as.character(x)
  out <- suppressWarnings(as.integer(x))
  ifelse(!is.na(out), out, as.integer(sub(".*GS0*([0-9]+)$", "\\1", x)))
}

# Cleans, filters (chromosomes 1-20), and sorts genomic data by position
prep <- function(df, method) {
  df %>%
    transmute(
      SNP = SNP,
      Chr_num = get_chr_num(Chr),
      Pos = as.numeric(Pos),
      P = as.numeric(P.value),
      method = method
    ) %>%
    filter(
      !is.na(Chr_num),
      Chr_num >= 1, Chr_num <= 20,
      !is.na(Pos),
      !is.na(P),
      P > 0
    ) %>%
    arrange(Chr_num, Pos)
}

# Preprocesses and labels GWAS results
farmcpu2 <- prep(farmcpu, "FarmCPU")
blink2    <- prep(blink, "BLINK")
mlmm2    <- prep(mlmm, "MLMM")

# Merges all methods, factors chromosomes (1-20), and calculates -log10(P) values
gwas <- bind_rows(farmcpu2, blink2, mlmm2) %>%
  mutate(
    Chr_num = factor(Chr_num, levels = 1:20),
    logp = -log10(P)
  )

# Build cumulative positions
chr_lengths <- gwas %>%
  group_by(Chr_num) %>%
  summarise(chr_len = max(Pos, na.rm = TRUE), .groups = "drop") %>%
  arrange(as.integer(as.character(Chr_num))) %>%
  mutate(offset = lag(cumsum(chr_len), default = 0))

gwas <- gwas %>%
  left_join(chr_lengths, by = "Chr_num") %>%
  mutate(pos_cum = Pos + offset)

axis_df <- chr_lengths %>%
  mutate(
    center = offset + chr_len / 2,
    lab = as.integer(as.character(Chr_num))
  )

# Customize colors
pink     <- "#8B0000"
orange   <- "#ECA700"
green    <- "#008C04"
blue     <- "#0084B8"
darkblue <- "#0C4E4E"

chr_cols <- rep(c(pink, orange, green, blue, darkblue), length.out = 20)
names(chr_cols) <- as.character(1:20)

# =============================================================================
# Plot
# =============================================================================

p <- ggplot(gwas, aes(x = pos_cum, y = logp)) +
  geom_point(
    aes(color = as.character(Chr_num), shape = method),
    size = 1.4,
    alpha = 0.7
  ) +
  geom_hline(
    yintercept = 8,
    colour = "red",
    linetype = "dashed",
    linewidth = 0.8
  ) +
  scale_color_manual(values = chr_cols, guide = "none") +
  scale_shape_manual(
    name   = "Model",
    values = c("FarmCPU" = 17,
               "BLINK"   = 16, 
               "MLMM"    = 15)
  ) +
  guides(shape = guide_legend(
    override.aes = list(size = 2.5, alpha = 1, color = "black")
  )) +
  scale_x_continuous(
    breaks = axis_df$center,
    labels = axis_df$lab,
    expand = expansion(mult = 0.006)
  ) +
  scale_y_continuous(
    breaks = c(3, 6, 9, 12),
    limits = c(0, 13),
    expand = expansion(mult = 0.02)
  ) +
  labs(
    x = "Chromosome",
    y = expression(-log[10](P))
  ) +
  theme_classic() +
  theme(
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x  = element_text(size = 10, colour = "black"),
    axis.text.y  = element_text(size = 10, colour = "black"),
    axis.title.x = element_text(size = 12, colour = "black", margin = margin(t = 10)),
    axis.title.y = element_text(size = 12, colour = "black", margin = margin(r = 8))
  )

jpeg("ManhattanPlot.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

print(p)
dev.off()
