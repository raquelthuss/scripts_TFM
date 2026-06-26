# =============================================================================
# GAPIT
# =============================================================================

library(readxl)
library(dplyr)
library(ggplot2)
library(readr)
library(lmerTest)
library(pbkrtest)
library(emmeans)
library(broom)
library(qvalue)
library(multtest)
library(scatterplot3d)
library(GAPIT)

rm(list = ls())
setwd("~/Desktop/1.LAB/TFM/GAPIT/pop_str_prunned_WP/")

# =============================================================================
# Data
# =============================================================================

# Genotype data
# -------------

myG <- read.table(
  "../myHapMap_limpio.hmp.txt",
  header = FALSE,
  sep = "\t",
  stringsAsFactors = FALSE,
  comment.char = "",
  check.names = FALSE,
  quote = ""
)

# Clean sample names by removing suffixes from genotype columns
myG[1, 12:ncol(myG)] <- sub("_.*$", "", myG[1, 12:ncol(myG)])

# Remove duplicated genotype columns
geno_cols <- colnames(myG)[12:ncol(myG)]
unique_geno_cols <- !duplicated(geno_cols)

# Remove last column and standardize sample ID column name
myG <- myG[, c(1:11, which(unique_geno_cols) + 11)] 

# Covariate data
# --------------

# Load population structure covariates (Q matrix)
myCV <- read.table("../Qmatrix_K3.txt", header = TRUE)
myCV <- myCV[, -ncol(myCV)]
colnames(myCV)[1] <- "Taxa"

# Remove duplicated accessions
myCV <- myCV %>% distinct(Taxa, .keep_all = TRUE)
head(myCV)

# Phenotype data
# ---------------

# # Load phenotype data (estimated marginal means)
pheno <- read.csv("../../phenotype/emmeans_pruned_log.csv", header = TRUE, sep = ",")

# Keep accession IDs and phenotype values
myY <- pheno[, c(1,6)]
colnames(myY) <- c("Taxa", "Pheno")

# Subset data
# -----------

# Extract accession IDs from genotype, phenotype, and covariate datasets
taxaG <- as.character(unlist(myG[1, 12:ncol(myG)]))
taxaY <- as.character(myY$Taxa)
taxaCV <- as.character(myCV$Taxa)
commonTaxa <- Reduce(intersect, list(taxaG, taxaY, taxaCV))

# Subset genotype data to common accessions
g_sample_idx <- match(commonTaxa, taxaG)
stopifnot(!any(is.na(g_sample_idx)))
myG_subset <- myG[, c(1:11, 11 + g_sample_idx)]     

# Subset phenotype data to common accessions
myY_subset <- myY %>%
  filter(Taxa %in% commonTaxa) %>%
  mutate(Taxa = as.character(Taxa)) %>%
  dplyr::slice(match(commonTaxa, Taxa))

# Subset covariate data to common accessions
myCV_subset <- myCV %>%
  filter(Taxa %in% commonTaxa) %>%
  mutate(Taxa = as.character(Taxa)) %>%
  dplyr::slice(match(commonTaxa, Taxa))

# =============================================================================
## Run GAPIT with multiple models
# =============================================================================

gwasmodels <- c("GLM", "FarmCPU", "Blink" ,"MLMM", "MLM")

GAPIT(
  Y = myY_subset,
  G = myG_subset,
  CV = myCV_subset,
  PCA.total = 0,
  SNP.MAF = 0.01,
  model = gwasmodels,
  Multiple_analysis = TRUE
)

# Calculate Bonferroni threshold
n_snps <- nrow(myG_subset)-1
umbral_bonferroni <- 0.05 / n_snps
umbral_bonferroni
