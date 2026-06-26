# =============================================================================
# Linkage disequilibrium (LD) decay
# =============================================================================

library(ggplot2)
library(dplyr)

setwd("~/Desktop/1.LAB/TFM/LD")

# =============================================================================
# Data
# =============================================================================

# Load LD values for the entire chromosome and for the specific LD06 region
ld_data <- read.table("Weight_per_nodule/Gs16_12963807_G-A_whole_chr.ld", header = TRUE, stringsAsFactors = FALSE)
ld_data_LD06 <- read.table("Weight_per_nodule/Gs16:12963807:G-A_LD06.ld", header = TRUE)

# Divide by 1e6 to get Megabases for a readable x-axis
ld_data <- ld_data %>%
  mutate(Posicion_Cromosomica_Mb = BP_B / 1000000)

# Save position of the SNP of interes (same for all rows)
qtn_abs_mb <- ld_data$BP_A[1] / 1000000

# Define LD06 window (flanking markers)
region_start <- ld_data_LD06$BP_B[7] / 1000000
region_end   <- ld_data_LD06$BP_B[98] / 1000000

# =============================================================================
# Plot
# =============================================================================

p <- ggplot(ld_data, aes(x = Posicion_Cromosomica_Mb, y = R2)) +
  geom_point(alpha = 0.3, color = "#0C4E4E") +
    geom_smooth(method = "gam", color = "red", se = FALSE, linewidth = 1.2) +
    geom_vline(xintercept = c(region_start, region_end), color = "red", linetype = "dashed", linewidth = 0.8) +

  labs(x = "Distance along chromosome 16 (Mb)",
       y = expression(r^2)) +
  
  scale_x_continuous(breaks = seq(0, 60, by = 5)) +
  theme_minimal(base_size = 11) +
  theme(
    axis.title.y     = element_text(margin = margin(r = 15), size = 12),
    axis.title.x     = element_text(margin = margin(t = 10), size = 12),
    axis.text.x      = element_text(size = 10),
    axis.text.y      = element_text(size = 10), 
  )

jpeg("LD_region_Gs16jpg", 
     width = 1900,          
     height = 1500,         
     res = 300,             
     quality = 95)          

print(p)
dev.off()
