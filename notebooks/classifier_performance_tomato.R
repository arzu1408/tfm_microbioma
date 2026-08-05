# ============================================
# Script 4 - Tomato Classifier Performance
# Paula Arzuza Jaimes
# ============================================

samples <- c("SRR16079617", "SRR16079618", "SRR16079619",
             "SRR16079614", "SRR16079615", "SRR16079616")
condition <- c("Healthy", "Healthy", "Healthy",
               "Diseased", "Diseased", "Diseased")

# Kraken2
get_kraken_stats <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/kraken2_tomato/",
              sample, "_kraken2_report.txt")
  df <- read.table(f, header = FALSE, sep = "\t", quote = "")
  colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
  unclassified_pct <- df[df$rank == "U", "pct"][1]
  classified_pct <- 100 - unclassified_pct
  data.frame(sample = sample, classified_pct = round(classified_pct, 2))
}

# Centrifuge
get_centrifuge_stats <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/centrifuge_tomato/",
              sample, "_centrifuge_kreport.txt")
  df <- read.table(f, header = FALSE, sep = "\t", quote = "")
  colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
  unclassified_pct <- df[df$rank == "U", "pct"][1]
  classified_pct <- 100 - unclassified_pct
  data.frame(sample = sample, classified_pct = round(classified_pct, 2))
}

kraken_stats <- do.call(rbind, lapply(samples, get_kraken_stats))
centrifuge_stats <- do.call(rbind, lapply(samples, get_centrifuge_stats))

summary_table <- data.frame(
  sample = samples,
  condition = condition,
  kraken2_pct = kraken_stats$classified_pct,
  centrifuge_pct = centrifuge_stats$classified_pct
)

cat("=== TOMATO CLASSIFIER PERFORMANCE SUMMARY ===\n")
print(summary_table)

cat("\nMean classification rates:\n")
cat("Kraken2:", round(mean(summary_table$kraken2_pct), 2), "%\n")
cat("Centrifuge:", round(mean(summary_table$centrifuge_pct), 2), "%\n")

write.csv(summary_table,
          "/mnt/d/tfm_data/results/diversity_tomato/classifier_performance_summary_tomato.csv",
          row.names = FALSE)

cat("\nSummary table saved\n")
cat("Script 4 complete!\n")
