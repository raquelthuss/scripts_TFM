# =============================================================================
# Boxplot showing nodule size distribution: Gs16_12963807: G-A
# =============================================================================

# Load packages
library(tidyverse)
library(readxl)
library(glmmTMB)
library(emmeans)
library(dplyr)
library(FSA)

setwd("~/Desktop/1.LAB/TFM/GAPIT")
rm(list = ls())

# =============================================================================
# 1. DATA
# =============================================================================

# Prepare genotype data
# ---------------------
geno <- read.table("genotipo_Gs16_12963807.txt", header = TRUE, sep = "\t",
                   check.names = FALSE, comment.char = "")

# Clean column names
colnames(geno) <- gsub("^#?\\[\\d+\\]|:GT$", "", colnames(geno))
colnames(geno)

# Convert genotype matrix from wide to long format
geno_long <- geno %>%
  pivot_longer(cols = -c(CHROM, POS, REF, ALT), names_to = "sample", values_to = "GT") %>%
  mutate(
    sample = gsub("^\\[\\d+\\]|:GT$", "", sample),
    genotipo = case_when(
      GT %in% c("0/0", "0|0") ~ "REF/REF",
      GT %in% c("0/1", "1/0", "0|1", "1|0") ~ "REF/ALT",
      GT %in% c("1/1", "1|1") ~ "ALT/ALT",
      TRUE ~ NA_character_
    ),
    genotipo = factor(genotipo, levels = c("REF/REF", "REF/ALT", "ALT/ALT"))
  )

# Check genotype counts
table(geno_long$genotipo)

# Simplify sample IDs
geno_long$sample <- sub("_.*", "", geno_long$sample)

# Relabel genotype categories usign allele anotation
geno_long$genotipo <- factor(geno_long$genotipo, 
                             levels = c("REF/REF", "REF/ALT", "ALT/ALT"), 
                             labels = c("GG", "GA", "AA"))
head(geno_long)

# Remove accesiones with 0 nodules
remove_samples <- c("132", "134", "212")

geno_long <- geno_long %>% 
  filter(!sample %in% remove_samples)

# Prepare phenotype data
# ----------------------
sheet_names <- excel_sheets("../phenotype/results_GWAS.xlsx")

df <- map2_dfr(sheet_names, seq_along(sheet_names), ~ {
  read_excel("../phenotype/results_GWAS.xlsx",
             sheet = .x,
             col_types = "text") %>%
    mutate(Lote = as.character(.y))
})

# Load sample metadata
key <- read_excel("../phenotype/meta.xlsx", sheet = 2)

# Merge GWAS results with metadata using accession ID
df_joined <- df %>%
  inner_join(key %>%
               select(Orig_number, Species, Type, Type_2,
                      Country, Collection, Continent,
                      Ex_1, Ex_2, Ex_3),
             by = "Orig_number")

# Remove non inoculated control samples, outliers and samples with 0 nodules
df_clean <- df_joined %>%
  filter(
    !(GWAS_num %in% c("control_1_NI", "control_2_NI", "control_3_NI")),
    (is.na(Outliers) | Outliers == ""),
    !(Orig_number %in% c(132, 134, 212, 231))
  )

# Convert response variable to numeric and categorical variables to factors
df_model <- df_clean %>%
  mutate(
    Weight_per_nodule = as.numeric(Weight_per_nodule),
    
    Genotype = as.factor(Orig_number),
    Species  = as.factor(Species),
    
    Rep   = as.factor(Rep),
    Batch = as.factor(Batch),
    Block = as.factor(Block)
  )

# Fit a Gamma GLMM with genotype as fixed effect and block as random effect
# small offset avoids zero issues safely

fit_gamma_log <- glmmTMB(
  Weight_per_nodule + 0.001 ~ Genotype + (1|Block2),
  data = df_model,
  family = Gamma(link = "log"))

#============================================================================
# 2. EMMEANS
# =============================================================================

# Extract estimated marginal means and standard errors for each genotype
emmeans_WP <- emmeans(fit_gamma_log, ~ Genotype, type = "response")
emmeans_WP <- as.data.frame(emmeans_WP) %>%
  select(Genotype, response, SE) %>%
  rename(
    !!paste0("Weight_per_nodule", "_mean") := response,
    !!paste0("Weight_per_nodule", "_SE") := SE)

# Create genotype-to-species mapping
species_key <- df_model %>%
  distinct(Genotype, Species)

# Add species information to EMM results
final <- emmeans_WP %>%
  left_join(species_key, by = "Genotype")

# Keep only G. soja accessions
final_soja <- final %>%
  filter(Species == "G. soja")

names(final_soja)[1] <- "sample"

#============================================================================
# 3. Statistical comparison of nodule weight between genotypes
# =============================================================================

# Merge genotype and phenotype data
df_plot <- geno_long %>%
  left_join(final_soja, by = "sample")

# Calculate mean nodule weight for each genotype
mean_by_genotype <- df_plot %>%
  group_by(genotipo) %>%
  summarise(mean_weight = mean(Weight_per_nodule_mean, na.rm = TRUE))

# Compute percentage differences in mean weight between genotype groups
(mean_by_genotype$mean_weight[1] - mean_by_genotype$mean_weight[3]) / 
  mean_by_genotype$mean_weight[3] * 100

(mean_by_genotype$mean_weight[1] - mean_by_genotype$mean_weight[2]) / 
  mean_by_genotype$mean_weight[2] * 100

# Split data by genotype group
group_GG <- df_plot$Weight_per_nodule_mean[df_plot$genotipo == "GG"]
group_AA <- df_plot$Weight_per_nodule_mean[df_plot$genotipo == "AA"]
group_GA <- df_plot$Weight_per_nodule_mean[df_plot$genotipo == "GA"]

# Test normality for each genotype group
shapiro.test(group_GG)
shapiro.test(group_AA)
shapiro.test(group_GA)

# Since data are not normally distributed, perform a Kruskal-Wallis test
kruskal.test(Weight_per_nodule_mean ~ genotipo, data = df_plot)

# Perform post-hoc pairwise comparisons (Kruskal-Wallis is significant)
dunnTest(Weight_per_nodule_mean ~ genotipo, data = df_plot, method = "bonferroni")

#============================================================================
# 4. Boxplot
# =============================================================================

p <- ggplot(df_plot, aes(x = genotipo, y = Weight_per_nodule_mean)) +
  geom_boxplot(color = "black", linewidth = 0.8, outlier.shape = NA, width = 0.6) +
  geom_jitter(shape = 1, color = "#8B0000", size = 2.5, stroke = 0.7, 
              width = 0.15, height = 0) +
  ggsignif::geom_signif(comparisons = list(c("GG", "GA")), 
              annotations = "*", 
              y_position = max(df_plot$Weight_per_nodule_mean, na.rm = TRUE) * 1.02,
              tip_length = 0.02) +
  
  ggsignif::geom_signif(comparisons = list(c("GG", "AA")), 
              annotations = "**", 
              y_position = max(df_plot$Weight_per_nodule_mean, na.rm = TRUE) * 1.12,
              tip_length = 0.02) +
  labs(x = "Gs16:12963807:G-A", y = "Nodule size (g)") +
  theme_classic(base_size = 11) +
  theme(
    axis.title.x = element_text(size = 12, margin = margin(t = 10, r = 0, b = 0, l = 0)),
    axis.title.y = element_text(size = 10, margin = margin(t = 0, r = 15, b = 0, l = 0)),
    axis.text = element_text(size = 10),
    axis.line = element_line(linewidth = 0.8)
  )

jpeg("Boxplot_Gs16.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

print(p)
dev.off()