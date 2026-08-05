# ============================================
# Script 2 - Tomato Classifier Comparison
# Paula Arzuza Jaimes
# ============================================

library(ggplot2)

samples <- c("SRR16079617", "SRR16079618", "SRR16079619",
             "SRR16079614", "SRR16079615", "SRR16079616")
condition <- c("Healthy", "Healthy", "Healthy",
               "Diseased", "Diseased", "Diseased")

# ============================================
# 1. CLASSIFICATION RATES
# ============================================

kraken2_pct <- c(0.36, 0.21, 0.37, 0.46, 0.50, 0.31)
centrifuge_pct <- c(28.93, 25.87, 27.03, 29.93, 31.61, 30.42)

rates_df <- data.frame(
  sample = rep(samples, 2),
  condition = rep(condition, 2),
  classifier = c(rep("Kraken2", 6), rep("Centrifuge", 6)),
  pct = c(kraken2_pct, centrifuge_pct)
)

p_rates <- ggplot(rates_df, aes(x = sample, y = pct, fill = classifier)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Kraken2" = "#2196F3", "Centrifuge" = "#FF9800")) +
  labs(title = "Classification Rates - Tomato Rhizosphere",
       x = "Sample", y = "% Classified Reads", fill = "Classifier") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity_tomato/classification_rates_tomato.png",
       p_rates, width = 10, height = 6, dpi = 300)
cat("Classification rates plot saved\n")

# ============================================
# 2. SPEARMAN CORRELATION KRAKEN2 VS CENTRIFUGE
# ============================================

get_genus_abundances <- function(sample, classifier) {
  if (classifier == "kraken2") {
    f <- paste0("/mnt/d/tfm_data/results/kraken2_tomato/",
                sample, "_bracken_genus.txt")
    df <- read.table(f, header = TRUE, sep = "\t")
    return(setNames(df$fraction_total_reads, df$name))
  } else {
    f <- paste0("/mnt/d/tfm_data/results/centrifuge_tomato/",
                sample, "_centrifuge_kreport.txt")
    df <- read.table(f, header = FALSE, sep = "\t")
    colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
    df_genus <- df[df$rank == "G", ]
    total <- sum(df_genus$reads)
    if (total == 0) return(named_vector <- setNames(numeric(0), character(0)))
    return(setNames(df_genus$reads / total, trimws(df_genus$name)))
  }
}

# Get genus abundances for all samples
k2_genera <- lapply(samples, get_genus_abundances, classifier = "kraken2")
cf_genera <- lapply(samples, get_genus_abundances, classifier = "centrifuge")

# Find common genera across all samples
all_k2_genera <- unique(unlist(lapply(k2_genera, names)))
all_cf_genera <- unique(unlist(lapply(cf_genera, names)))
common_genera <- intersect(all_k2_genera, all_cf_genera)

cat("\nCommon genera between Kraken2 and Centrifuge:", length(common_genera), "\n")

if (length(common_genera) > 5) {
  k2_mean <- sapply(common_genera, function(g) {
    mean(sapply(k2_genera, function(x) ifelse(g %in% names(x), x[g], 0)))
  })
  cf_mean <- sapply(common_genera, function(g) {
    mean(sapply(cf_genera, function(x) ifelse(g %in% names(x), x[g], 0)))
  })

  spearman_result <- cor.test(k2_mean, cf_mean, method = "spearman")
  cat("Spearman r:", round(spearman_result$estimate, 3), "\n")
  cat("p-value:", spearman_result$p.value, "\n")

  cor_df <- data.frame(kraken2 = k2_mean, centrifuge = cf_mean,
                        genus = common_genera)

  p_cor <- ggplot(cor_df, aes(x = kraken2, y = centrifuge)) +
    geom_point(alpha = 0.6, size = 2, color = "#1F5C8B") +
    geom_smooth(method = "lm", se = FALSE, color = "#F44336") +
    labs(title = paste0("Kraken2 vs Centrifuge - Spearman r=",
                        round(spearman_result$estimate, 3),
                        " p=", format(spearman_result$p.value, scientific = TRUE, digits = 3)),
         x = "Kraken2 genus relative abundance",
         y = "Centrifuge genus relative abundance") +
    theme_bw()

  ggsave("/mnt/d/tfm_data/results/diversity_tomato/spearman_correlation_tomato.png",
         p_cor, width = 8, height = 6, dpi = 300)
  cat("Spearman correlation plot saved\n")
} else {
  cat("Too few common genera for correlation analysis\n")
}

cat("\nScript 2 complete!\n")
