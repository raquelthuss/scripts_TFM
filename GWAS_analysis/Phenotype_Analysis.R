# =============================================================================
# Genotype-level adjusted means (EMMeans)
# =============================================================================

rm(list = ls())
options(scipen = 999)

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

# =============================================================================
# 3. Gamma GLMM model
# =============================================================================

# Fit a Gamma GLMM with genotype as fixed effect and block as random effect
# small offset avoids zero issues safely

# Gamma GLMM with a square-root link function: does not converge
fit_gamma_sqrt <- glmmTMB(
  Weight_per_nodule + 0.001 ~ Genotype + (1|Block2),
  data = df_model,
  family = Gamma(link = "sqrt"))

# Gamma GLMM with a log link function
fit_gamma_log <- glmmTMB(
  Weight_per_nodule + 0.001 ~ Genotype + (1|Block2),
  data = df_model,
  family = Gamma(link = "log"))

# =============================================================================
# 4. DIAGNOSTICS (DHARMa)
# =============================================================================

# Evaluate model 
model_diag <- function(model) {
  # Simulate residuals
  sim <- DHARMa::simulateResiduals(model, n = 1000)
  # Return diagnostic test p-values and model AIC
  list(
    uniformity = DHARMa::testUniformity(sim, plot = F)$p.value,
    dispersion = DHARMa::testDispersion(sim, plot = F)$p.value,
    outliers   = DHARMa::testOutliers(sim, type = "binomial", plot = F)$p.value,
    AIC        = AIC(model),
    sim_obj    = sim
  )
}

sqrt_diag <- model_diag(fit_gamma_sqrt) # does not represent a good fit
print(sqrt_diag)
log_diag <- model_diag(fit_gamma_log)
print(log_diag)

# Save QQ-plot for Gamma GLMM with log link function
jpeg("QQ_plot_DHARMa.jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

plotQQunif(log_diag$sim_obj, testUniformity = F, testDispersion = F, testOutliers = F)

dev.off()

#============================================================================
# 5. EMMEANS
# =============================================================================

# # Extract estimated marginal means and standard errors for each genotype
emmeans_WP <- emmeans(fit_gamma_log, ~ Genotype)
emmeans_WP <- as.data.frame(emmeans_WP) %>%
  select(Genotype, emmean, SE) %>%
  rename(
    !!paste0("Weight_per_nodule", "_mean") := emmean,
    !!paste0("Weight_per_nodule", "_SE") := SE)

# =============================================================================
# 6. MERGE RESULTS
# =============================================================================

species_key <- df_model %>%
  distinct(Genotype, Species)

final <- emmeans_WP %>%
  left_join(species_key, by = "Genotype")

final_soja <- final %>%
  filter(Species == "G. soja")

# =============================================================================
# 7. SAVE
# =============================================================================

write.csv(final_soja,
          "emmeans_GLMM_log.csv",
          row.names = FALSE)
