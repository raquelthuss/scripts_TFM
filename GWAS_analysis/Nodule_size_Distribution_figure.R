# =============================================================================
# Trait distribution across genotypes
# =============================================================================

library(ggplot2)
library(car)
library(tidyverse)
library(readxl)
library(lme4)
library(lmerTest)
library(emmeans)
library(glmmTMB)
library(DHARMa)
library(bbmle)

setwd("~/Desktop/1.LAB/TFM/phenotype")

# =============================================================================
# 1. DATA
# =============================================================================

# Load phenotyping data
sheet_names <- excel_sheets("./results_GWAS.xlsx")

df <- map2_dfr(sheet_names, seq_along(sheet_names), ~ {
  read_excel("./results_GWAS.xlsx",
             sheet = .x,
             col_types = "text") %>%
    mutate(Lote = as.character(.y))
})

# Load sample metadata
key <- read_excel("./meta.xlsx", sheet = 2)

# Merge phenotype with metadata using accession ID
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

# Gamma GLMM with a log link function
fit_gamma_log <- glmmTMB(
  Weight_per_nodule + 0.001 ~ Genotype + (1|Block2),
  data = df_model,
  family = Gamma(link = "log"))

# Extract estimated marginal means and standard errors for each genotype
emmeans_WP <- emmeans(fit_gamma_log, ~ Genotype)
emmeans_WP <- as.data.frame(emmeans_WP) %>%
  select(Genotype, emmean, SE) %>%
  rename(
    !!paste0("Weight_per_nodule", "_mean") := emmean,
    !!paste0("Weight_per_nodule", "_SE") := SE)

# Perform a Type II Wald chi-square test to evaluate the significance of genotype
Anova(fit_gamma_log, type = "II")

# =============================================================================
# 2. Plot
# =============================================================================

p <- ggplot(
  emmeans_WP_plot %>% arrange(Weight_per_nodule_mean),
  aes(
    x = reorder(Genotype, Weight_per_nodule_mean),
    y = Weight_per_nodule_mean
  )
) +
  geom_col(fill = "#008C04") +
  geom_errorbar(
    aes(
      ymin = Weight_per_nodule_mean - Weight_per_nodule_SE,
      ymax = Weight_per_nodule_mean + Weight_per_nodule_SE
    ),
    width = 0.2,
    linewidth = 0.3
  ) +
  
  annotate(
    "text", 
    x = 4,          
    y = 0.024,      
    label = "Wald~chi^2*(281) == 8419.1*','~italic(p) < 0.001", 
    parse = TRUE,   
    hjust = 0,      
    size = 3.8
  ) +
  
  scale_y_continuous(expand = c(0.01, 0), 
                     limits = c(0, 0.026),
                     breaks = seq(0, 0.026, by = 0.005),
                     labels = scales::label_number(accuracy = 0.001)) +
  
  theme_classic(base_size = 11) +
  labs(
    x = "Accessions",
    y = "Average nodule size (g)"
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

print(p_)

dev.off()
