# ============================================
# Script 2 - Classifier Comparison
# Paula Arzuza Jaimes
# ============================================

library(ggplot2)
library(reshape2)

# ============================================
# 1. CLASSIFICATION RATES COMPARISON
# ============================================

samples <- c("DRR318378", "DRR318379", "DRR318380", 
             "DRR318381", "DRR318382", "DRR318383")
condition <- c("Wildtype", "Wildtype", "Wildtype",
               "phr1phl1", "phr1phl1", "phr1phl1")

# Classification rates from our results
kraken2_classified <- c(0.89, 0.72, 0.77, 1.05, 0.67, 0.75)
centrifuge_classified <- c(34.30, 33.06, 33.87, 34.42, 32.34, 33.54)
metaphlan4_classified <- c(100, 100, 100, 100, 100, 100)

rates_df <- data.frame(
  sample = rep(samples, 3),
  condition = rep(condition, 3),
  classifier = c(rep("Kraken2", 6), rep("Centrifuge", 6), rep("MetaPhlAn4", 6)),
  classified = c(kraken2_classified, centrifuge_classified, metaphlan4_classified)
)

# Plot classification rates
p_rates <- ggplot(rates_df, aes(x = sample, y = classified, fill = classifier)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Kraken2" = "#E91E63",
                                "Centrifuge" = "#2196F3",
                                "MetaPhlAn4" = "#4CAF50")) +
  labs(title = "Classification Rates by Classifier",
       x = "Sample", y = "% Reads Classified",
       fill = "Classifier") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity/classification_rates.png",
       p_rates, width = 10, height = 6, dpi = 300)

cat("Classification rates plot saved\n")

# ============================================
# 2. LOAD GENUS LEVEL DATA FOR CORRELATION
# ============================================

# Load Kraken2 Bracken genus results
load_bracken <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/kraken2/", sample, "_bracken_genus.txt")
  df <- read.table(f, header=TRUE, sep="\t", quote="")
  df <- df[, c("name", "fraction_total_reads")]
  colnames(df) <- c("genus", sample)
  return(df)
}

# Load Centrifuge kreport genus results
load_centrifuge <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/centrifuge/", sample, "_centrifuge_kreport.txt")
  df <- read.table(f, header=FALSE, sep="\t", quote="")
  colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
  df <- df[df$rank == "G", c("name", "pct")]
  df$name <- trimws(df$name)
  colnames(df) <- c("genus", sample)
  return(df)
}

# Load all samples
kraken_list <- lapply(samples, load_bracken)
kraken_merged <- Reduce(function(x,y) merge(x, y, by="genus", all=TRUE), kraken_list)
kraken_merged[is.na(kraken_merged)] <- 0
rownames(kraken_merged) <- kraken_merged$genus
kraken_merged$genus <- NULL

centrifuge_list <- lapply(samples, load_centrifuge)
centrifuge_merged <- Reduce(function(x,y) merge(x, y, by="genus", all=TRUE), centrifuge_list)
centrifuge_merged[is.na(centrifuge_merged)] <- 0
rownames(centrifuge_merged) <- centrifuge_merged$genus
centrifuge_merged$genus <- NULL

cat("Kraken2 genera:", nrow(kraken_merged), "\n")
cat("Centrifuge genera:", nrow(centrifuge_merged), "\n")

# ============================================
# 3. SPEARMAN CORRELATION
# ============================================

# Find common genera
common_genera <- intersect(rownames(kraken_merged), rownames(centrifuge_merged))
cat("Common genera between Kraken2 and Centrifuge:", length(common_genera), "\n")

if(length(common_genera) > 5) {
  kraken_common <- rowMeans(kraken_merged[common_genera, ])
  centrifuge_common <- rowMeans(centrifuge_merged[common_genera, ])
  
  spearman <- cor.test(kraken_common, centrifuge_common, method = "spearman")
  cat("Spearman correlation Kraken2 vs Centrifuge:", round(spearman$estimate, 3), "\n")
  cat("p-value:", spearman$p.value, "\n")
  
  # Scatter plot
  cor_df <- data.frame(
    kraken2 = kraken_common,
    centrifuge = centrifuge_common,
    genus = common_genera
  )
  
  p_cor <- ggplot(cor_df, aes(x = kraken2, y = centrifuge)) +
    geom_point(alpha = 0.6, size = 2, color = "#673AB7") +
    geom_smooth(method = "lm", se = TRUE, color = "red") +
    labs(title = paste0("Kraken2 vs Centrifuge (Spearman r = ", 
                        round(spearman$estimate, 3), ")"),
         x = "Kraken2 mean relative abundance",
         y = "Centrifuge mean relative abundance") +
    theme_bw()
  
  ggsave("/mnt/d/tfm_data/results/diversity/spearman_correlation.png",
         p_cor, width = 7, height = 6, dpi = 300)
  
  cat("Spearman correlation plot saved\n")
} else {
  cat("Not enough common genera for correlation\n")
}

cat("\nScript 2 complete!\n")
